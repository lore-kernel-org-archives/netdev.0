From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: No link on e1000e with 2.6.35.3 and ThinkPad T60
Date: Thu, 26 Aug 2010 19:14:42 +0200
Message-ID: <20100826171442.GA22941@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de>
	<20100824094524.GA17608@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A136600821444B@rrsmsx501.amr.corp.intel.com>
	<20100826112732.GA15559@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"e1000-devel@lists.so
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20100826112732.GA15559@torres.zugschlus.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Aug 26, 2010 at 01:27:32PM +0200, Marc Haber wrote:
> On Wed, Aug 25, 2010 at 12:01:40PM -0600, Tantilov, Emil S wrote:
> > We have a tool that you can use to dump the registers from the port in the failed state:
> > http://sourceforge.net/projects/e1000/files/Ethregs%20-%20Register%20Dump%20Tool/ethregs-1.12.3/
> 
> Attached, for an interface in the working state. I'll deliver another
> regdump when I see the issue again

Here we go, with a non-working interface.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190

--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename=20100826-ethregs2

02:00.0 (8086:109a)
Intel Corporation 82573L Gigabit Ethernet Controller
	Name           Value
	~~~~           ~~~~~
	CTRL           00140248
	STATUS         80080780
	EECD           06008318
	EERD           ffb20012
	CTRL_EXT       08780000
	FLA            00000600
	MDIC           18217949
	FCAL           00c28001
	FCAH           00000100
	FCT            00008808
	VET            00008100
	ITR            000003d0
	ICS            00000000
	IMS            0000009d
	IMC            0000009d
	IAM            ffffffff
	RCTL           04048002
	FCTTV          00000680
	TCTL           3103f0f8
	TIPG           00602008
	AIT            00000000
	LEDCTL         000f8b02
	EXTCNF_CTRL    0014000a
	EXTCNF_SIZE    00000004
	PBA            000c0014
	PBS            00000020
	EEMNGCTL       80000000
	EEARBC         001d0290
	FLASHT         00000002
	EEWR           00000002
	FLSWCTL        c0000000
	FLSWDATA       00000000
	FLSWCNT        00000000
	FLOP           0004db00
	ERT            00000000
	FCRTL          800047f8
	FCRTH          00004800
	PSRCTL         00040402
	RDBAL          35c82000
	RDBAH          00000000
	RDLEN          00001000
	RDH            00000000
	RDT            000000f0
	RDTR           00000000
	RXDCTL         00010000
	RADV           00000008
	RDBAL1         00000000
	RDBAH1         00000000
	RDLEN1         00000000
	RDH1           00000000
	RDT1           00000000
	RSRPD          00000000
	RAID           00000000
	CPUVEC         00000000
	TDFH           00000a00
	TDFT           00000a00
	TDFHS          00000a00
	TDFTS          00000a00
	TDFPC          00000000
	TDBAL          33260000
	TDBAH          00000000
	TDLEN          00001000
	TDH            00000000
	TDT            00000000
	TIDV           00000008
	TXDCTL         01410000
	TADV           00000020
	TARC0          00000403
	TDBAL1         00000000
	TDBAH1         00000000
	TDLEN1         00000000
	TDH1           00000000
	TDT1           00000000
	TXDCTL1        00400000
	TARC1          00000403
	ICRXPTC        00000000
	ICRXATC        00000000
	ICTXPTC        00000000
	ICTXATC        00000000
	ICTXQEC        00000000
	ICTXQMTC       00000000
	ICRXDMTC       00000000
	ICRXOC         00000000
	RXCSUM         00000300
	RFCTL          00000000
	MTA[0]         00010000
	MTA[1]         00000000
	MTA[2]         00000000
	MTA[3]         00000000
	MTA[4]         00000000
	MTA[5]         00000000
	MTA[6]         00000000
	MTA[7]         00000001
	MTA[8]         00000000
	MTA[9]         00000000
	MTA[10]        00000000
	MTA[11]        00000000
	MTA[12]        00000000
	MTA[13]        00000000
	MTA[14]        00000000
	MTA[15]        00000000
	MTA[16]        00000000
	MTA[17]        00000000
	MTA[18]        00000000
	MTA[19]        00000000
	MTA[20]        00000000
	MTA[21]        00000000
	MTA[22]        00000000
	MTA[23]        00000000
	MTA[24]        00000000
	MTA[25]        00000000
	MTA[26]        00000000
	MTA[27]        00000000
	MTA[28]        00000000
	MTA[29]        00000000
	MTA[30]        00000000
	MTA[31]        00000000
	MTA[32]        00000000
	MTA[33]        00000000
	MTA[34]        00000000
	MTA[35]        00000000
	MTA[36]        00000000
	MTA[37]        00000000
	MTA[38]        00000000
	MTA[39]        00000000
	MTA[40]        00000000
	MTA[41]        00000000
	MTA[42]        00000000
	MTA[43]        00000000
	MTA[44]        00000000
	MTA[45]        00000000
	MTA[46]        00000000
	MTA[47]        00000000
	MTA[48]        00000000
	MTA[49]        00000000
	MTA[50]        00000000
	MTA[51]        00000000
	MTA[52]        00000000
	MTA[53]        00000000
	MTA[54]        00000000
	MTA[55]        00000000
	MTA[56]        00000000
	MTA[57]        00000000
	MTA[58]        00000000
	MTA[59]        00000000
	MTA[60]        00000000
	MTA[61]        00000000
	MTA[62]        00000000
	MTA[63]        00000000
	MTA[64]        00000000
	MTA[65]        00000000
	MTA[66]        00000000
	MTA[67]        00000000
	MTA[68]        00000000
	MTA[69]        00000000
	MTA[70]        00000000
	MTA[71]        00000000
	MTA[72]        00000000
	MTA[73]        00000000
	MTA[74]        00000000
	MTA[75]        00000000
	MTA[76]        00000000
	MTA[77]        00000000
	MTA[78]        00000000
	MTA[79]        00000000
	MTA[80]        00000000
	MTA[81]        00000000
	MTA[82]        00000000
	MTA[83]        00000000
	MTA[84]        00000000
	MTA[85]        00000000
	MTA[86]        00000000
	MTA[87]        00000000
	MTA[88]        00000000
	MTA[89]        00000000
	MTA[90]        00000000
	MTA[91]        00000000
	MTA[92]        00000000
	MTA[93]        00000000
	MTA[94]        00000000
	MTA[95]        00000000
	MTA[96]        00000000
	MTA[97]        00000000
	MTA[98]        00000000
	MTA[99]        00000000
	MTA[100]       00000000
	MTA[101]       00000000
	MTA[102]       00000000
	MTA[103]       00000000
	MTA[104]       00000000
	MTA[105]       00000000
	MTA[106]       00000000
	MTA[107]       00000000
	MTA[108]       00000000
	MTA[109]       00000000
	MTA[110]       00000000
	MTA[111]       00000000
	MTA[112]       00000000
	MTA[113]       00000000
	MTA[114]       00000000
	MTA[115]       00000000
	MTA[116]       00000000
	MTA[117]       00000000
	MTA[118]       00000000
	MTA[119]       00000000
	MTA[120]       00000000
	MTA[121]       00000000
	MTA[122]       00000000
	MTA[123]       00000000
	MTA[124]       00000000
	MTA[125]       00000000
	MTA[126]       00000000
	MTA[127]       00000000
	RAL[0]         6a6b1a00
	RAH[0]         80006007
	RAL[1]         00000000
	RAH[1]         00000000
	RAL[2]         00000000
	RAH[2]         00000000
	RAL[3]         00000000
	RAH[3]         00000000
	RAL[4]         00000000
	RAH[4]         00000000
	RAL[5]         00000000
	RAH[5]         00000000
	RAL[6]         00000000
	RAH[6]         00000000
	RAL[7]         00000000
	RAH[7]         00000000
	RAL[8]         00000000
	RAH[8]         00000000
	RAL[9]         00000000
	RAH[9]         00000000
	RAL[10]        00000000
	RAH[10]        00000000
	RAL[11]        00000000
	RAH[11]        00000000
	RAL[12]        00000000
	RAH[12]        00000000
	RAL[13]        00000000
	RAH[13]        00000000
	RAL[14]        00000000
	RAH[14]        00000000
	RAL[15]        00000000
	RAH[15]        00000000
	VFTA[0]        00000000
	VFTA[1]        00000000
	VFTA[2]        00000000
	VFTA[3]        00000000
	VFTA[4]        00000000
	VFTA[5]        00000000
	VFTA[6]        00000000
	VFTA[7]        00000000
	VFTA[8]        00000000
	VFTA[9]        00000000
	VFTA[10]       00000000
	VFTA[11]       00000000
	VFTA[12]       00000000
	VFTA[13]       00000000
	VFTA[14]       00000000
	VFTA[15]       00000000
	VFTA[16]       00000000
	VFTA[17]       00000000
	VFTA[18]       00000000
	VFTA[19]       00000000
	VFTA[20]       00000000
	VFTA[21]       00000000
	VFTA[22]       00000000
	VFTA[23]       00000000
	VFTA[24]       00000000
	VFTA[25]       00000000
	VFTA[26]       00000000
	VFTA[27]       00000000
	VFTA[28]       00000000
	VFTA[29]       00000000
	VFTA[30]       00000000
	VFTA[31]       00000000
	VFTA[32]       00000000
	VFTA[33]       00000000
	VFTA[34]       00000000
	VFTA[35]       00000000
	VFTA[36]       00000000
	VFTA[37]       00000000
	VFTA[38]       00000000
	VFTA[39]       00000000
	VFTA[40]       00000000
	VFTA[41]       00000000
	VFTA[42]       00000000
	VFTA[43]       00000000
	VFTA[44]       00000000
	VFTA[45]       00000000
	VFTA[46]       00000000
	VFTA[47]       00000000
	VFTA[48]       00000000
	VFTA[49]       00000000
	VFTA[50]       00000000
	VFTA[51]       00000000
	VFTA[52]       00000000
	VFTA[53]       00000000
	VFTA[54]       00000000
	VFTA[55]       00000000
	VFTA[56]       00000000
	VFTA[57]       00000000
	VFTA[58]       00000000
	VFTA[59]       00000000
	VFTA[60]       00000000
	VFTA[61]       00000000
	VFTA[62]       00000000
	VFTA[63]       00000000
	VFTA[64]       00000000
	VFTA[65]       00000000
	VFTA[66]       00000000
	VFTA[67]       00000000
	VFTA[68]       00000000
	VFTA[69]       00000000
	VFTA[70]       00000000
	VFTA[71]       00000000
	VFTA[72]       00000000
	VFTA[73]       00000000
	VFTA[74]       00000000
	VFTA[75]       00000000
	VFTA[76]       00000000
	VFTA[77]       00000000
	VFTA[78]       00000000
	VFTA[79]       00000000
	VFTA[80]       00000000
	VFTA[81]       00000000
	VFTA[82]       00000000
	VFTA[83]       00000000
	VFTA[84]       00000000
	VFTA[85]       00000000
	VFTA[86]       00000000
	VFTA[87]       00000000
	VFTA[88]       00000000
	VFTA[89]       00000000
	VFTA[90]       00000000
	VFTA[91]       00000000
	VFTA[92]       00000000
	VFTA[93]       00000000
	VFTA[94]       00000000
	VFTA[95]       00000000
	VFTA[96]       00000000
	VFTA[97]       00000000
	VFTA[98]       00000000
	VFTA[99]       00000000
	VFTA[100]      00000000
	VFTA[101]      00000000
	VFTA[102]      00000000
	VFTA[103]      00000000
	VFTA[104]      00000000
	VFTA[105]      00000000
	VFTA[106]      00000000
	VFTA[107]      00000000
	VFTA[108]      00000000
	VFTA[109]      00000000
	VFTA[110]      00000000
	VFTA[111]      00000000
	VFTA[112]      00000000
	VFTA[113]      00000000
	VFTA[114]      00000000
	VFTA[115]      00000000
	VFTA[116]      00000000
	VFTA[117]      00000000
	VFTA[118]      00000000
	VFTA[119]      00000000
	VFTA[120]      00000000
	VFTA[121]      00000000
	VFTA[122]      00000000
	VFTA[123]      00000000
	VFTA[124]      00000000
	VFTA[125]      00000000
	VFTA[126]      00000000
	VFTA[127]      00000000
	WUC            00000000
	WUFC           00000000
	WUS            00000000
	MRQC           00000000
	MANC           00000100
	IPAV           00000000
	MANC2H         00000000
	RSSIM          00000000
	RSSIR          00000000
	WUPL           83138b1d
	GCR            0e000000
	GSCL_1         00000000
	GSCL_2         00000000
	GSCL_3         00000000
	GSCL_4         00000000
	FACTPS         a1041046
	FWSM           00000000
	RETA[0]        00000026
	RETA[1]        000000c0
	RETA[2]        00000002
	RETA[3]        00000096
	RETA[4]        00000005
	RETA[5]        00000044
	RETA[6]        0000005b
	RETA[7]        00000095
	RETA[8]        0000000c
	RETA[9]        000000f1
	RETA[10]       0000005f
	RETA[11]       0000009d
	RETA[12]       0000003d
	RETA[13]       000000c3
	RETA[14]       000000e0
	RETA[15]       00000036
	RETA[16]       000000d5
	RETA[17]       000000d6
	RETA[18]       0000000d
	RETA[19]       00000052
	RETA[20]       00000095
	RETA[21]       000000c5
	RETA[22]       00000023
	RETA[23]       00000000
	RETA[24]       0000009b
	RETA[25]       000000a0
	RETA[26]       0000002c
	RETA[27]       0000001c
	RETA[28]       0000002c
	RETA[29]       000000f0
	RETA[30]       0000003a
	RETA[31]       0000001b
	RETA[32]       0000008d
	RETA[33]       000000a5
	RETA[34]       0000002d
	RETA[35]       000000d2
	RETA[36]       00000000
	RETA[37]       00000061
	RETA[38]       0000000a
	RETA[39]       00000021
	RETA[40]       00000005
	RETA[41]       0000002c
	RETA[42]       00000012
	RETA[43]       00000064
	RETA[44]       0000002a
	RETA[45]       000000c4
	RETA[46]       0000004a
	RETA[47]       00000014
	RETA[48]       00000011
	RETA[49]       000000d9
	RETA[50]       000000db
	RETA[51]       0000009c
	RETA[52]       00000095
	RETA[53]       000000c9
	RETA[54]       000000aa
	RETA[55]       00000055
	RETA[56]       0000009d
	RETA[57]       000000c7
	RETA[58]       00000043
	RETA[59]       00000090
	RETA[60]       000000c5
	RETA[61]       00000088
	RETA[62]       00000022
	RETA[63]       00000020
	RETA[64]       000000d1
	RETA[65]       000000f9
	RETA[66]       0000000b
	RETA[67]       0000009c
	RETA[68]       00000061
	RETA[69]       00000051
	RETA[70]       0000008a
	RETA[71]       000000dc
	RETA[72]       0000000d
	RETA[73]       000000b1
	RETA[74]       000000b3
	RETA[75]       00000036
	RETA[76]       000000c0
	RETA[77]       000000c6
	RETA[78]       000000c8
	RETA[79]       00000036
	RETA[80]       000000a1
	RETA[81]       00000038
	RETA[82]       0000000e
	RETA[83]       000000ce
	RETA[84]       00000007
	RETA[85]       000000f4
	RETA[86]       00000003
	RETA[87]       00000011
	RETA[88]       00000080
	RETA[89]       000000cc
	RETA[90]       0000008a
	RETA[91]       00000016
	RETA[92]       00000005
	RETA[93]       000000dc
	RETA[94]       00000003
	RETA[95]       000000b4
	RETA[96]       00000045
	RETA[97]       000000c1
	RETA[98]       0000000e
	RETA[99]       00000050
	RETA[100]      00000088
	RETA[101]      000000d7
	RETA[102]      0000004b
	RETA[103]      00000034
	RETA[104]      000000bd
	RETA[105]      00000094
	RETA[106]      00000088
	RETA[107]      0000001c
	RETA[108]      0000001a
	RETA[109]      000000f4
	RETA[110]      00000004
	RETA[111]      00000054
	RETA[112]      000000c8
	RETA[113]      000000d5
	RETA[114]      0000000f
	RETA[115]      00000054
	RETA[116]      00000036
	RETA[117]      00000047
	RETA[118]      000000ce
	RETA[119]      0000006c
	RETA[120]      000000c9
	RETA[121]      000000c5
	RETA[122]      000000a2
	RETA[123]      0000001c
	RETA[124]      00000099
	RETA[125]      000000c5
	RETA[126]      00000048
	RETA[127]      000000d6
	RSSRK[0]       00000000
	RSSRK[1]       00000000
	RSSRK[2]       00000000
	RSSRK[3]       00000000
	RSSRK[4]       00000000
	RSSRK[5]       00000000
	RSSRK[6]       00000000
	RSSRK[7]       00000000
	RSSRK[8]       00000000
	RSSRK[9]       00000000
	RSSRK[10]      00000000
	RSSRK[11]      00000000
	RSSRK[12]      00000000
	RSSRK[13]      00000000
	RSSRK[14]      00000000
	RSSRK[15]      00000000
	RSSRK[16]      00000000
	RSSRK[17]      00000000
	RSSRK[18]      00000000
	RSSRK[19]      00000000
	RSSRK[20]      00000000
	RSSRK[21]      00000000
	RSSRK[22]      00000000
	RSSRK[23]      00000000
	RSSRK[24]      00000000
	RSSRK[25]      00000000
	RSSRK[26]      00000000
	RSSRK[27]      00000000
	RSSRK[28]      00000000
	RSSRK[29]      00000000
	RSSRK[30]      00000000
	RSSRK[31]      00000000
	RSSRK[32]      00000000
	RSSRK[33]      00000000
	RSSRK[34]      00000000
	RSSRK[35]      00000000
	RSSRK[36]      00000000
	RSSRK[37]      00000000
	RSSRK[38]      00000000
	RSSRK[39]      00000000
	FFLT[0]        00000000
	FFLT[1]        fffc0000
	FFLT[2]        00000000
	FFLT[3]        00000000
	FFLT[4]        00000000
	FFLT[5]        00000000
	FFLT[6]        00000000
	FFLT[7]        00000000
	FFLT[8]        00000000
	FFLT[9]        00000000
	FFLT[10]       00000000
	FFLT[11]       00000000
	HICR           00000000
	FFMT[0]        00000005
	FFMT[1]        00000005
	FFMT[2]        00000008
	FFMT[3]        00000008
	FFMT[4]        0000000a
	FFMT[5]        0000000a
	FFMT[6]        0000000e
	FFMT[7]        0000000e
	FFMT[8]        00000005
	FFMT[9]        00000005
	FFMT[10]       0000000b
	FFMT[11]       0000000b
	FFMT[12]       0000000f
	FFMT[13]       0000000f
	FFMT[14]       00000005
	FFMT[15]       00000005
	FFMT[16]       0000000b
	FFMT[17]       0000000b
	FFMT[18]       0000000b
	FFMT[19]       0000000b
	FFMT[20]       00000001
	FFMT[21]       00000001
	FFMT[22]       0000000c
	FFMT[23]       0000000c
	FFMT[24]       0000000b
	FFMT[25]       0000000b
	FFMT[26]       00000009
	FFMT[27]       00000009
	FFMT[28]       00000009
	FFMT[29]       00000009
	FFMT[30]       0000000f
	FFMT[31]       0000000f
	FFMT[32]       00000004
	FFMT[33]       00000004
	FFMT[34]       0000000f
	FFMT[35]       0000000f
	FFMT[36]       00000009
	FFMT[37]       00000009
	FFMT[38]       0000000a
	FFMT[39]       0000000a
	FFMT[40]       00000003
	FFMT[41]       00000003
	FFMT[42]       00000006
	FFMT[43]       00000006
	FFMT[44]       0000000b
	FFMT[45]       0000000b
	FFMT[46]       0000000e
	FFMT[47]       0000000e
	FFMT[48]       00000004
	FFMT[49]       00000004
	FFMT[50]       0000000c
	FFMT[51]       0000000c
	FFMT[52]       00000001
	FFMT[53]       00000001
	FFMT[54]       0000000e
	FFMT[55]       0000000e
	FFMT[56]       00000004
	FFMT[57]       00000004
	FFMT[58]       00000002
	FFMT[59]       00000002
	FFMT[60]       00000006
	FFMT[61]       00000006
	FFMT[62]       00000007
	FFMT[63]       00000007
	FFMT[64]       00000009
	FFMT[65]       00000009
	FFMT[66]       00000009
	FFMT[67]       00000009
	FFMT[68]       00000008
	FFMT[69]       00000008
	FFMT[70]       0000000a
	FFMT[71]       0000000a
	FFMT[72]       00000008
	FFMT[73]       00000008
	FFMT[74]       0000000f
	FFMT[75]       0000000f
	FFMT[76]       00000004
	FFMT[77]       00000004
	FFMT[78]       00000007
	FFMT[79]       00000007
	FFMT[80]       0000000a
	FFMT[81]       0000000a
	FFMT[82]       0000000c
	FFMT[83]       0000000c
	FFMT[84]       0000000e
	FFMT[85]       0000000e
	FFMT[86]       0000000a
	FFMT[87]       0000000a
	FFMT[88]       0000000e
	FFMT[89]       0000000e
	FFMT[90]       0000000d
	FFMT[91]       0000000d
	FFMT[92]       00000009
	FFMT[93]       00000009
	FFMT[94]       0000000b
	FFMT[95]       0000000b
	FFMT[96]       0000000f
	FFMT[97]       0000000f
	FFMT[98]       0000000f
	FFMT[99]       0000000f
	FFMT[100]      0000000d
	FFMT[101]      0000000d
	FFMT[102]      00000003
	FFMT[103]      00000003
	FFMT[104]      00000007
	FFMT[105]      00000007
	FFMT[106]      0000000d
	FFMT[107]      0000000d
	FFMT[108]      00000006
	FFMT[109]      00000006
	FFMT[110]      0000000a
	FFMT[111]      0000000a
	FFMT[112]      0000000f
	FFMT[113]      0000000f
	FFMT[114]      00000003
	FFMT[115]      00000003
	FFMT[116]      00000008
	FFMT[117]      00000008
	FFMT[118]      0000000a
	FFMT[119]      0000000a
	FFMT[120]      00000008
	FFMT[121]      00000008
	FFMT[122]      00000006
	FFMT[123]      00000006
	FFMT[124]      00000008
	FFMT[125]      00000008
	FFMT[126]      0000000c
	FFMT[127]      0000000c
	FFVT[0]        a6063fca
	FFVT[1]        a6063fca
	FFVT[2]        2ca3a3e4
	FFVT[3]        2ca3a3e4
	FFVT[4]        6f2cabeb
	FFVT[5]        6f2cabeb
	FFVT[6]        ee9e7aa6
	FFVT[7]        ee9e7aa6
	FFVT[8]        f199b24b
	FFVT[9]        f199b24b
	FFVT[10]       59402795
	FFVT[11]       59402795
	FFVT[12]       d43d3fac
	FFVT[13]       d43d3fac
	FFVT[14]       ff863f28
	FFVT[15]       ff863f28
	FFVT[16]       5adfa5fe
	FFVT[17]       5adfa5fe
	FFVT[18]       9d1feab8
	FFVT[19]       9d1feab8
	FFVT[20]       d565ef35
	FFVT[21]       d565ef35
	FFVT[22]       32a4199c
	FFVT[23]       32a4199c
	FFVT[24]       722a0d7a
	FFVT[25]       722a0d7a
	FFVT[26]       2f3ef537
	FFVT[27]       2f3ef537
	FFVT[28]       e8838f4d
	FFVT[29]       e8838f4d
	FFVT[30]       b51a35ee
	FFVT[31]       b51a35ee
	FFVT[32]       a869766e
	FFVT[33]       a869766e
	FFVT[34]       8eea93c7
	FFVT[35]       8eea93c7
	FFVT[36]       c9e13bf9
	FFVT[37]       c9e13bf9
	FFVT[38]       70c55b36
	FFVT[39]       70c55b36
	FFVT[40]       410b6e11
	FFVT[41]       410b6e11
	FFVT[42]       b9280132
	FFVT[43]       b9280132
	FFVT[44]       a1ff1349
	FFVT[45]       a1ff1349
	FFVT[46]       1e0eae0f
	FFVT[47]       1e0eae0f
	FFVT[48]       9a689127
	FFVT[49]       9a689127
	FFVT[50]       756dfb5e
	FFVT[51]       756dfb5e
	FFVT[52]       f14cec3a
	FFVT[53]       f14cec3a
	FFVT[54]       b6c7c3a8
	FFVT[55]       b6c7c3a8
	FFVT[56]       5e9de386
	FFVT[57]       5e9de386
	FFVT[58]       b6585cfd
	FFVT[59]       b6585cfd
	FFVT[60]       a3edd429
	FFVT[61]       a3edd429
	FFVT[62]       58ad6893
	FFVT[63]       58ad6893
	FFVT[64]       2beeb5ce
	FFVT[65]       2beeb5ce
	FFVT[66]       a374b07d
	FFVT[67]       a374b07d
	FFVT[68]       16d5c741
	FFVT[69]       16d5c741
	FFVT[70]       d31c9e12
	FFVT[71]       d31c9e12
	FFVT[72]       5c6f4bac
	FFVT[73]       5c6f4bac
	FFVT[74]       26ab7f96
	FFVT[75]       26ab7f96
	FFVT[76]       070285cb
	FFVT[77]       070285cb
	FFVT[78]       81eb2296
	FFVT[79]       81eb2296
	FFVT[80]       4fa5c85d
	FFVT[81]       4fa5c85d
	FFVT[82]       a4b49ef6
	FFVT[83]       a4b49ef6
	FFVT[84]       8704daa6
	FFVT[85]       8704daa6
	FFVT[86]       d4d6854d
	FFVT[87]       d4d6854d
	FFVT[88]       dc4ed51e
	FFVT[89]       dc4ed51e
	FFVT[90]       16e92cb6
	FFVT[91]       16e92cb6
	FFVT[92]       4a3c04d2
	FFVT[93]       4a3c04d2
	FFVT[94]       e0c9684f
	FFVT[95]       e0c9684f
	FFVT[96]       1b5bd6dc
	FFVT[97]       1b5bd6dc
	FFVT[98]       05f7009c
	FFVT[99]       05f7009c
	FFVT[100]      32ba7139
	FFVT[101]      32ba7139
	FFVT[102]      74505c5d
	FFVT[103]      74505c5d
	FFVT[104]      b4094977
	FFVT[105]      b4094977
	FFVT[106]      991b641e
	FFVT[107]      991b641e
	FFVT[108]      87a5d935
	FFVT[109]      87a5d935
	FFVT[110]      732b29fc
	FFVT[111]      732b29fc
	FFVT[112]      a39ba2c5
	FFVT[113]      a39ba2c5
	FFVT[114]      41229835
	FFVT[115]      41229835
	FFVT[116]      c9800969
	FFVT[117]      c9800969
	FFVT[118]      a7126b02
	FFVT[119]      a7126b02
	FFVT[120]      a82d87de
	FFVT[121]      a82d87de
	FFVT[122]      aaeacb52
	FFVT[123]      aaeacb52
	FFVT[124]      eaf7ba12
	FFVT[125]      eaf7ba12
	FFVT[126]      bbc9065e
	FFVT[127]      bbc9065e



--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename=20100826-dmidecode2

# dmidecode 2.9
SMBIOS 2.4 present.
68 structures occupying 2250 bytes.
Table at 0x000E0010.

Handle 0x0000, DMI type 0, 24 bytes
BIOS Information
	Vendor: LENOVO
	Version: 7IET27WW (1.08 )
	Release Date: 04/30/2007
	Address: 0xDC000
	Runtime Size: 144 kB
	ROM Size: 2048 kB
	Characteristics:
		PCI is supported
		PC Card (PCMCIA) is supported
		PNP is supported
		BIOS is upgradeable
		BIOS shadowing is allowed
		ESCD support is available
		Boot from CD is supported
		Selectable boot is supported
		BIOS ROM is socketed
		EDD is supported
		ACPI is supported
		USB legacy is supported
		BIOS boot specification is supported
		Targeted content distribution is supported
	BIOS Revision: 1.8
	Firmware Revision: 1.7

Handle 0x0001, DMI type 1, 27 bytes
System Information
	Manufacturer: LENOVO
	Product Name: 87424SG
	Version: ThinkPad T60
	Serial Number: L3B7271
	UUID: A75A5301-4935-11CB-B962-9F269485B8ED
	Wake-up Type: Power Switch
	SKU Number: Not Specified
	Family: ThinkPad T60

Handle 0x0002, DMI type 2, 8 bytes
Base Board Information
	Manufacturer: LENOVO
	Product Name: 87424SG
	Version: Not Available
	Serial Number: VF0TV76H11J

Handle 0x0003, DMI type 3, 13 bytes
Chassis Information
	Manufacturer: LENOVO
	Type: Notebook
	Lock: Not Present
	Version: Not Available
	Serial Number: Not Available
	Asset Tag: No Asset Information
	Boot-up State: Unknown
	Power Supply State: Unknown
	Thermal State: Unknown
	Security Status: Unknown

Handle 0x0004, DMI type 126, 13 bytes
Inactive

Handle 0x0005, DMI type 126, 13 bytes
Inactive

Handle 0x0006, DMI type 4, 35 bytes
Processor Information
	Socket Designation: None
	Type: Central Processor
	Family: Other
	Manufacturer: GenuineIntel
	ID: F6 06 00 00 FF FB EB BF
	Version: Intel(R) Core(TM)2 CPU         
	Voltage: 1.3 V
	External Clock: 167 MHz
	Max Speed: 2167 MHz
	Current Speed: 2167 MHz
	Status: Populated, Enabled
	Upgrade: None
	L1 Cache Handle: 0x000A
	L2 Cache Handle: 0x000C
	L3 Cache Handle: Not Provided
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified

Handle 0x0007, DMI type 5, 20 bytes
Memory Controller Information
	Error Detecting Method: None
	Error Correcting Capabilities:
		None
	Supported Interleave: One-way Interleave
	Current Interleave: One-way Interleave
	Maximum Memory Module Size: 2048 MB
	Maximum Total Memory Size: 4096 MB
	Supported Speeds:
		Other
	Supported Memory Types:
		DIMM
		SDRAM
	Memory Module Voltage: 2.9 V
	Associated Memory Slots: 2
		0x0008
		0x0009
	Enabled Error Correcting Capabilities:
		Unknown

Handle 0x0008, DMI type 6, 12 bytes
Memory Module Information
	Socket Designation: DIMM Slot 1
	Bank Connections: 0 3
	Current Speed: Unknown
	Type: DIMM SDRAM
	Installed Size: 2048 MB (Double-bank Connection)
	Enabled Size: 2048 MB (Double-bank Connection)
	Error Status: OK

Handle 0x0009, DMI type 6, 12 bytes
Memory Module Information
	Socket Designation: DIMM Slot 2
	Bank Connections: 4 7
	Current Speed: Unknown
	Type: DIMM SDRAM
	Installed Size: 2048 MB (Double-bank Connection)
	Enabled Size: 2048 MB (Double-bank Connection)
	Error Status: OK

Handle 0x000A, DMI type 7, 19 bytes
Cache Information
	Socket Designation: Internal L1 Cache
	Configuration: Enabled, Socketed, Level 1
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 64 KB
	Maximum Size: 64 KB
	Supported SRAM Types:
		Synchronous
	Installed SRAM Type: Synchronous
	Speed: Unknown
	Error Correction Type: Single-bit ECC
	System Type: Instruction
	Associativity: 8-way Set-associative

Handle 0x000B, DMI type 7, 19 bytes
Cache Information
	Socket Designation: Internal L1 Cache
	Configuration: Enabled, Socketed, Level 1
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 64 KB
	Maximum Size: 64 KB
	Supported SRAM Types:
		Synchronous
	Installed SRAM Type: Synchronous
	Speed: Unknown
	Error Correction Type: Single-bit ECC
	System Type: Data
	Associativity: 8-way Set-associative

Handle 0x000C, DMI type 7, 19 bytes
Cache Information
	Socket Designation: Internal L2 Cache
	Configuration: Enabled, Socketed, Level 2
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 4096 KB
	Maximum Size: 4096 KB
	Supported SRAM Types:
		Burst
	Installed SRAM Type: Burst
	Speed: Unknown
	Error Correction Type: Single-bit ECC
	System Type: Unified
	Associativity: 8-way Set-associative

Handle 0x000D, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: Infrared
	External Connector Type: Infrared
	Port Type: Other

Handle 0x000E, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: External Monitor
	External Connector Type: DB-15 female
	Port Type: Video Port

Handle 0x000F, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: Microphone Jack
	External Connector Type: Mini Jack (headphones)
	Port Type: Audio Port

Handle 0x0010, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: Headphone Jack
	External Connector Type: Mini Jack (headphones)
	Port Type: Audio Port

Handle 0x0011, DMI type 126, 9 bytes
Inactive

Handle 0x0012, DMI type 126, 9 bytes
Inactive

Handle 0x0013, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: Modem
	External Connector Type: RJ-11
	Port Type: Modem Port

Handle 0x0014, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: Ethernet
	External Connector Type: RJ-45
	Port Type: Network Port

Handle 0x0015, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: USB 1
	External Connector Type: Access Bus (USB)
	Port Type: USB

Handle 0x0016, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: USB 2
	External Connector Type: Access Bus (USB)
	Port Type: USB

Handle 0x0017, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: Not Available
	Internal Connector Type: None
	External Reference Designator: USB 3
	External Connector Type: Access Bus (USB)
	Port Type: USB

Handle 0x0018, DMI type 126, 9 bytes
Inactive

Handle 0x0019, DMI type 126, 9 bytes
Inactive

Handle 0x001A, DMI type 126, 9 bytes
Inactive

Handle 0x001B, DMI type 126, 9 bytes
Inactive

Handle 0x001C, DMI type 126, 9 bytes
Inactive

Handle 0x001D, DMI type 126, 9 bytes
Inactive

Handle 0x001E, DMI type 126, 9 bytes
Inactive

Handle 0x001F, DMI type 126, 9 bytes
Inactive

Handle 0x0020, DMI type 9, 13 bytes
System Slot Information
	Designation: ExpressCard Slot 1
	Type: x1 PCI Express
	Current Usage: Available
	Length: Other
	ID: 0
	Characteristics:
		Hot-plug devices are supported

Handle 0x0021, DMI type 9, 13 bytes
System Slot Information
	Designation: CardBus Slot 1
	Type: 32-bit PC Card (PCMCIA)
	Current Usage: Available
	Length: Other
	ID: Adapter 1, Socket 0
	Characteristics:
		5.0 V is provided
		3.3 V is provided
		PC Card-16 is supported
		Cardbus is supported
		Zoom Video is supported
		Modem ring resume is supported
		PME signal is supported
		Hot-plug devices are supported

Handle 0x0022, DMI type 126, 13 bytes
Inactive

Handle 0x0023, DMI type 126, 13 bytes
Inactive

Handle 0x0024, DMI type 126, 13 bytes
Inactive

Handle 0x0025, DMI type 10, 6 bytes
On Board Device Information
	Type: Other
	Status: Disabled
	Description: IBM Embedded Security hardware

Handle 0x0026, DMI type 11, 5 bytes
OEM Strings
	String 1: IBM ThinkPad Embedded Controller -[79HT50WW-1.07    ]-

Handle 0x0027, DMI type 13, 22 bytes
BIOS Language Information
	Installable Languages: 1
		enUS
	Currently Installed Language: enUS

Handle 0x0028, DMI type 15, 25 bytes
System Event Log
	Area Length: 0 bytes
	Header Start Offset: 0x0000
	Header Length: 16 bytes
	Data Start Offset: 0x0010
	Access Method: General-purpose non-volatile data functions
	Access Address: 0x0000
	Status: Valid, Full
	Change Token: 0x000000FE
	Header Format: Type 1
	Supported Log Type Descriptors: 1
	Descriptor 1: POST error
	Data Format 1: POST results bitmap

Handle 0x0029, DMI type 16, 15 bytes
Physical Memory Array
	Location: System Board Or Motherboard
	Use: System Memory
	Error Correction Type: None
	Maximum Capacity: 2 GB
	Error Information Handle: Not Provided
	Number Of Devices: 2

Handle 0x002A, DMI type 17, 27 bytes
Memory Device
	Array Handle: 0x0029
	Error Information Handle: No Error
	Total Width: 64 bits
	Data Width: 64 bits
	Size: 2048 MB
	Form Factor: SODIMM
	Set: None
	Locator: DIMM 1
	Bank Locator: Bank 0/1
	Type: DDR2
	Type Detail: Synchronous
	Speed: Unknown
	Manufacturer: Not Specified
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified

Handle 0x002B, DMI type 17, 27 bytes
Memory Device
	Array Handle: 0x0029
	Error Information Handle: No Error
	Total Width: 64 bits
	Data Width: 64 bits
	Size: 2048 MB
	Form Factor: SODIMM
	Set: None
	Locator: DIMM 2
	Bank Locator: Bank 2/3
	Type: DDR2
	Type Detail: Synchronous
	Speed: Unknown
	Manufacturer: Not Specified
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified

Handle 0x002C, DMI type 18, 23 bytes
32-bit Memory Error Information
	Type: OK
	Granularity: Unknown
	Operation: Unknown
	Vendor Syndrome: Unknown
	Memory Array Address: Unknown
	Device Address: Unknown
	Resolution: Unknown

Handle 0x002D, DMI type 19, 15 bytes
Memory Array Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x000FFFFFFFF
	Range Size: 4 GB
	Physical Array Handle: 0x0029
	Partition Width: 0

Handle 0x002E, DMI type 20, 19 bytes
Memory Device Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x0007FFFFFFF
	Range Size: 2 GB
	Physical Device Handle: 0x002A
	Memory Array Mapped Address Handle: 0x002D
	Partition Row Position: 1

Handle 0x002F, DMI type 20, 19 bytes
Memory Device Mapped Address
	Starting Address: 0x00080000000
	Ending Address: 0x000FFFFFFFF
	Range Size: 2 GB
	Physical Device Handle: 0x002B
	Memory Array Mapped Address Handle: 0x002D
	Partition Row Position: 1

Handle 0x0030, DMI type 21, 7 bytes
Built-in Pointing Device
	Type: Track Point
	Interface: PS/2
	Buttons: 3

Handle 0x0031, DMI type 21, 7 bytes
Built-in Pointing Device
	Type: Touch Pad
	Interface: PS/2
	Buttons: 0

Handle 0x0032, DMI type 24, 5 bytes
Hardware Security
	Power-On Password Status: Disabled
	Keyboard Password Status: Disabled
	Administrator Password Status: Disabled
	Front Panel Reset Status: Unknown

Handle 0x0033, DMI type 32, 11 bytes
System Boot Information
	Status: No errors detected

Handle 0x0034, DMI type 131, 17 bytes
OEM-specific Type
	Header and Data:
		83 11 34 00 01 02 03 FF FF 1F 00 00 00 00 00 02
		00
	Strings:
		BOOTINF 20h
		BOOTDEV 21h
		KEYPTRS 23h

Handle 0x0035, DMI type 131, 11 bytes
OEM-specific Type
	Header and Data:
		83 0B 35 00 00 00 E8 FF C5 01 01
	Strings:
		IBM System Metrics

Handle 0x0036, DMI type 131, 22 bytes
OEM-specific Type
	Header and Data:
		83 16 36 00 01 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 01
	Strings:
		TVT-Enablement

Handle 0x0037, DMI type 132, 7 bytes
OEM-specific Type
	Header and Data:
		84 07 37 00 02 18 36

Handle 0x0038, DMI type 133, 5 bytes
OEM-specific Type
	Header and Data:
		85 05 38 00 01
	Strings:
		KHOIHGIUCCHHII

Handle 0x0039, DMI type 133, 17 bytes
OEM-specific Type
	Header and Data:
		85 11 39 00 30 30 2E 35 00 60 EF BF 00 00 00 00
		01
	Strings:
		Audit Boot History

Handle 0x003A, DMI type 134, 13 bytes
OEM-specific Type
	Header and Data:
		86 0D 3A 00 03 07 07 20 00 00 00 00 00

Handle 0x003B, DMI type 134, 16 bytes
OEM-specific Type
	Header and Data:
		86 10 3B 00 00 41 54 4D 4C 01 01 00 00 02 01 02
	Strings:
		TPM INFO
		System Reserved

Handle 0x003C, DMI type 135, 13 bytes
OEM-specific Type
	Header and Data:
		87 0D 3C 00 54 50 07 00 01 00 00 00 00

Handle 0x003D, DMI type 135, 18 bytes
OEM-specific Type
	Header and Data:
		87 12 3D 00 54 50 07 01 01 AC 00 00 00 00 00 00
		00 00

Handle 0x003E, DMI type 135, 35 bytes
OEM-specific Type
	Header and Data:
		87 23 3E 00 54 50 07 02 42 41 59 20 49 2F 4F 20
		01 00 02 00 00 0A 00 C8 18 AE 18 02 00 0E 00 F0
		01 F6 03

Handle 0x003F, DMI type 136, 6 bytes
OEM-specific Type
	Header and Data:
		88 06 3F 00 5A 5A

Handle 0x0040, DMI type 137, 28 bytes
OEM-specific Type
	Header and Data:
		89 1C 40 00 0C 02 00 01 01 00 C0 00 50 57 4D 53
		20 49 6E 66 6F 72 6D 61 74 69 6F 6E

Handle 0x0041, DMI type 138, 40 bytes
OEM-specific Type
	Header and Data:
		8A 28 41 00 14 01 01 01 07 01 01 0C 01 01 0C 01
		01 0C 00 00 42 49 4F 53 20 50 61 73 73 77 6F 72
		64 20 46 6F 72 6D 61 74

Handle 0x0042, DMI type 139, 37 bytes
OEM-specific Type
	Header and Data:
		8B 25 42 00 11 01 0A 00 00 00 00 00 00 00 00 00
		00 50 57 4D 53 20 4B 65 79 20 49 6E 66 6F 72 6D
		61 74 69 6F 6E

Handle 0x0043, DMI type 127, 4 bytes
End Of Table


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Sell apps to millions through the Intel(R) Atom(Tm) Developer Program
Be part of this innovative community and reach millions of netbook users 
worldwide. Take advantage of special opportunities to increase revenue and 
speed time-to-market. Join now, and jumpstart your future.
http://p.sf.net/sfu/intel-atom-d2d
--T4sUOijqQbZv57TR
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--T4sUOijqQbZv57TR--
