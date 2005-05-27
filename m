From: Jian Jun He <hejianj@cn.ibm.com>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test
 on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 18:12:57 +0800
Message-ID: <OFD9420708.88CB0182-ON4825700E.0037F856-4825700E.0037F913@cn.ibm.com>
References: <20050527012101.4b80c005.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6"
Cc: anton@samba.org, Dang En Ren <rende@cn.ibm.com>,
        ganesh.venkatesan@intel.com, ganesh.venkatesan@gmail.com,
        herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
        jgarzik@pobox.com, Jia Sen Wang <wangjs@cn.ibm.com>,
        john.ronciak@intel.com, Lei CDL Wang <cdlwangl@cn.ibm.com>,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050527012101.4b80c005.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6
Content-type: multipart/alternative;
	Boundary="1__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6"

--1__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable


I will verify it on 2.6.12-rc5-git2 when it is ready.


Best Regards!

Jian Jun He

CSDL, Beijing
Email: hejianj@cn.ibm.com



                                                                       =
    
             Andrew Morton                                             =
    
             <akpm@osdl.org>                                           =
    
                                                                       =
 To 
             2005-05-27 16:21          Jian Jun He/China/Contr/IBM@IBMC=
N   
                                                                       =
 cc 
                                       anton@samba.org, Dang En        =
    
                                       Ren/China/IBM@IBMCN,            =
    
                                       ganesh.venkatesan@gmail.com,    =
    
                                       ganesh.venkatesan@intel.com,    =
    
                                       herbert@gondor.apana.org.au,    =
    
                                       jesse.brandeburg@intel.com,     =
    
                                       jgarzik@pobox.com, Jia Sen      =
    
                                       Wang/China/IBM@IBMCN,           =
    
                                       john.ronciak@intel.com, Lei CDL =
    
                                       Wang/China/Contr/IBM@IBMCN,     =
    
                                       linuxppc64-dev@lists.linuxppc.or=
g.s 
                                       gi.com, netdev@oss.sgi.com      =
    
                                                                   Subj=
ect 
                                       Re: Fw: [Bugme-new] [Bug 4628] N=
ew: 
                                       Test server hang while running r=
hr  
                                       (network) test on RHEL4 with ker=
nel 
                                       2.6.12-rc1-mm4                  =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




Jian Jun He <hejianj@cn.ibm.com> wrote:
>
> I verified the problem on 2.6.12-rc5 with mm1 patch. The test server
works
>  find during the test procedure.

Great, thanks.

>  So I will close this defect in bugme.

Well we should verify that the e100 patches which Linus merged a few ho=
urs
ago did contain the fix.  So please test 2.6.12-rc5-git2, which should =
be
at ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots in ~8 hours.


=

--1__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>I will verify it on <tt>2.6.12-rc5-git2</tt> when it is ready.<br>
<br>
<br>
Best Regards!<br>
<br>
Jian Jun He<br>
<br>
CSDL, Beijing<br>
Email: hejianj@cn.ibm.com<br>
<br>
<img width=3D"16" height=3D"16" src=3D"cid:1__=3DC7BBFA9DDFA47EC68f9e8a=
93df938@cn.ibm.com" border=3D"0" alt=3D"Inactive hide details for Andre=
w Morton &lt;akpm@osdl.org&gt;">Andrew Morton &lt;akpm@osdl.org&gt;<br>=

<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:2__=3DC7BBFA9D=
DFA47EC68f9e8a93df938@cn.ibm.com); background-repeat: no-repeat; " widt=
h=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">Andrew Morton &lt;akpm@osdl.org&gt;</font></b><=
font size=3D"2"> </font>
<p><font size=3D"2">2005-05-27 16:21</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9DDFA47EC68f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Jian Jun He/China/Contr/IBM@IBMCN</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9DDFA47EC68f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">anton@samba.org, Dang En Ren/China/IBM@IBMCN, ganesh.v=
enkatesan@gmail.com, ganesh.venkatesan@intel.com, herbert@gondor.apana.=
org.au, jesse.brandeburg@intel.com, jgarzik@pobox.com, Jia Sen Wang/Chi=
na/IBM@IBMCN, john.ronciak@intel.com, Lei CDL Wang/China/Contr/IBM@IBMC=
N, linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com</font>=
</td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9DDFA47=
EC68f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang w=
hile running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4</fo=
nt></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img width=3D"1" height=3D"1" src=3D=
"cid:3__=3DC7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D=
""></td><td width=3D"336"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D=
C7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""></td></=
tr>
</table>
</td></tr>
</table>
<br>
<tt>Jian Jun He &lt;hejianj@cn.ibm.com&gt; wrote:<br>
&gt;<br>
&gt; I verified the problem on 2.6.12-rc5 with mm1 patch. The test serv=
er works<br>
&gt; &nbsp;find during the test procedure.<br>
<br>
Great, thanks.<br>
<br>
&gt; &nbsp;So I will close this defect in bugme.<br>
<br>
Well we should verify that the e100 patches which Linus merged a few ho=
urs<br>
ago did contain the fix. &nbsp;So please test 2.6.12-rc5-git2, which sh=
ould be<br>
at </tt><tt><a href=3D"ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snaps=
hots">ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots</a></tt><tt>=
&nbsp;in ~8 hours.<br>
<br>
<br>
</tt><br>
</body></html>=


--1__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6--


--0__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <1__=C7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6
Content-type: image/gif;
	name="pic10544.gif"
Content-Disposition: inline; filename="pic10544.gif"
Content-ID: <2__=C7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <3__=C7BBFA9DDFA47EC68f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=C7BBFA9DDFA47EC68f9e8a93df938690918cC7BBFA9DDFA47EC6--
