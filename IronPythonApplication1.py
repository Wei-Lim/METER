import clr
clr.AddReference('System.Drawing')
clr.AddReference('System.Windows.Forms')
clr.AddReference('System.IO')
clr.AddReference('System.Data')

from System.Drawing import *
from System.Windows.Forms import *
from System.IO import *
from System.Data import *
import xml.etree.ElementTree as ET

class MyForm(Form):
    def __init__(self):
        # Create child controls and initialize form
        self.Text = 'DelphinPy'
        self.MaximizeBox = False
        self.MinimizeBox = False
        self.ClientSize = Size(1024 , 768)
        self.label = Label()
        self.label.Text = "Bitte klick mich"
        self.label.Location = Point(50, 50)
        self.label.Height = 30
        self.label.Width = 200
        self.count = 0
        
        self.setupDataGridView()

        button = Button()
        button.Text = "Klick mich"
        button.Location = Point(50, 100)

        button.Click += self.buttonPressed

        self.Controls.Add(self.label)
        self.Controls.Add(button)

    def buttonPressed(self, sender, args):
        self.count += 1
        self.label.Text = "Du hast mich %s mal geklickt." % self.count
        self.analyzeXML();
        pass

    def analyzeXML(self):
        tree=ET.parse('1.xml')
        #self.dg1.Rows[0].Cells[0].Value = "1.xml"
        root = tree.getroot()
        temp_nodes= root.findall(".//*/Temperaturen")
        pruef_nodes=root.findall(".//*/Pruefschritte/*")
        Thermoelement_nodes=root.findall(".//*/Thermoelemente/*")
        #Anzahl an Prüfschritten (0,9 Un, 1,0 Un,... etc.)
        tempsteps_count=len(temp_nodes)
        #tempelements_count = root.findall(".//*/Thermoelemente").get('Anzahl')+1
        self.dg1.ColumnCount=50
        self.dg2.ColumnCount=50
        self.dg1.Columns[0].Name="Filename"
        self.dg2.Columns[0].Name="Filename"
        #Test....self.dg1.Rows.Add(str(tempelements_count))
        #Header in DG1 eintragen
        for index2,names in enumerate(temp_nodes):
            #temper_nodes = names.findall(".//*/Temperaturen")
            for index,temps in enumerate(names):
                #self.label.Text=temps.tag
                self.dg1.Columns[index+1+index2*8].Name=temps.tag + " " + pruef_nodes[index2].tag#temps.tag
        
        #Werte von messungen in DG1 eintragen
        for j,temps in enumerate(temp_nodes):
            self.dg1.Rows.Add("1.xml")
            for i,elements in enumerate(temps):
                self.dg1.Rows[0].Cells[i+1+j*8].Value=elements.get('Value')
        #Header in DG2 eintragen
        #for i1, elems in enumerate(Thermoelement_nodes):
            #self.dg2.Columns[i1].Name=elems.get('Beschreibung')
        pass

    def setupDataGridView(self):            
        self.dg1 = DataGridView()
        self.dg1.AllowUserToOrderColumns = False
        self.dg1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells
        #self.dg1.Dock = DockStyle.Fill
        self.dg1.Location = Point(50, 200)
        self.dg1.Size = Size(300, 300)
        #self.dg1.TabIndex = 2
        self.dg1.ColumnCount = 1
        #self.dg1.Columns[0]=DataGridView.TextColumn
        self.dg1.ColumnHeadersVisible = True
        self.dg1.RowHeadersVisible = False
        #self.dg1.Rows.Add()
           
        self.Controls.Add(self.dg1)

        self.dg2 = DataGridView()
        self.dg2.AllowUserToOrderColumns = False
        self.dg2.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells
        #self.dg1.Dock = DockStyle.Fill
        self.dg2.Location = Point(350, 200)
        self.dg2.Size = Size(300, 300)
        #self.dg1.TabIndex = 2
        self.dg2.ColumnCount = 1
        self.dg2.ColumnHeadersVisible = True
        self.dg2.RowHeadersVisible = False
        #self.dg1.Rows.Add()
           
        self.Controls.Add(self.dg2)

        self.dg3 = DataGridView()
        self.dg3.AllowUserToOrderColumns = False
        self.dg3.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells
        #self.dg1.Dock = DockStyle.Fill
        self.dg3.Location = Point(650, 200)
        self.dg3.Size = Size(300, 300)
        #self.dg1.TabIndex = 2
        self.dg3.ColumnCount = 1
        self.dg3.ColumnHeadersVisible = True
        self.dg3.RowHeadersVisible = False
        #self.dg1.Rows.Add()
           
        self.Controls.Add(self.dg3)


Application.EnableVisualStyles()
Application.SetCompatibleTextRenderingDefault(False)

form = MyForm()
Application.Run(form)
