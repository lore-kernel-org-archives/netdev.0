From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: who calls eth_header_cache_update
Date: Mon, 31 Jan 2005 18:09:27 +0530
Message-ID: <OF425B4DAB.80A86C49-ON87256F9A.0045799D-65256F9A.0045CEFB@us.ibm.com>
References: <1d55641b0501310427451b11@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D"
Cc: linux-net@vger.linux.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1d55641b0501310427451b11@mail.gmail.com>
To: cranium 2003 <cranium.2003@gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D
Content-type: multipart/alternative;
	Boundary="1__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D"

--1__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable






Check neigh_update_hss()....

- KK



                                                                       =
    
             cranium 2003                                              =
    
             <cranium.2003@gma                                         =
    
             il.com>                                                   =
 To 
             Sent by:                  netdev@oss.sgi.com,             =
    
             netdev-bounce@oss         linux-net@vger.linux.org        =
    
             .sgi.com                                                  =
 cc 
                                                                       =
    
                                                                   Subj=
ect 
             01/31/2005 05:57          who calls eth_header_cache_updat=
e   
             PM                                                        =
    
                                                                       =
    
                                                                       =
    
             Please respond to                                         =
    
               cranium 2003                                            =
    
                                                                       =
    
                                                                       =
    




Hello,
           Who need to call following function in linux kernel?
void eth_header_cache_update(struct hh_cache *hh, struct net_device
*dev, unsigned char * haddr)
{
        memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),=

               haddr, dev->addr_len);
}

regards,
cranium

=

--1__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Check neigh_update_hss()....<br>
<br>
- KK<br>
<br>
<img src=3D"cid:10__=3D08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com" width=3D=
"16" height=3D"16" alt=3D"Inactive hide details for cranium 2003 &lt;cr=
anium.2003@gmail.com&gt;">cranium 2003 &lt;cranium.2003@gmail.com&gt;<b=
r>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:20__=3D08BBE50=
9DFD6FF0D8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " wid=
th=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">cranium 2003 &lt;cranium.2003@gmail.com&gt;</fo=
nt></b><font size=3D"2"> </font><br>
<font size=3D"2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size=3D"2">01/31/2005 05:57 PM</font>
<table border=3D"1">
<tr valign=3D"top"><td width=3D"168" bgcolor=3D"#FFFFFF"><div align=3D"=
center"><font size=3D"2">Please respond to<br>
cranium 2003</font></div></td></tr>
</table>
</ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">netdev@oss.sgi.com, linux-net@vger.linux.org</font></t=
d></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
</td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img src=3D"cid:30__=3D08BBE509DFD6FF0D8f9e8a93df938@us.ibm.=
com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">who calls eth_header_cache_update</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img src=3D"cid:30__=3D08BBE509DFD6=
FF0D8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=
=3D""></td><td width=3D"336"><img src=3D"cid:30__=3D08BBE509DFD6FF0D8f9=
e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><=
/td></tr>
</table>
</td></tr>
</table>
<br>
<tt>Hello,<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Who need to call following function=
 in linux kernel?<br>
void eth_header_cache_update(struct hh_cache *hh, struct net_device<br>=

*dev, unsigned char * haddr)<br>
{<br>
 &nbsp; &nbsp; &nbsp; &nbsp;memcpy(((u8*)hh-&gt;hh_data) + HH_DATA_OFF(=
sizeof(struct ethhdr)),<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; haddr, dev-&gt;addr_l=
en);<br>
}<br>
<br>
regards,<br>
cranium<br>
<br>
</tt><br>
</body></html>=


--1__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D--


--0__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D
Content-type: image/gif;
	name="pic31540.gif"
Content-Disposition: inline; filename="pic31540.gif"
Content-ID: <20__=08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com>
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

--0__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <30__=08BBE509DFD6FF0D8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=08BBE509DFD6FF0D8f9e8a93df938690918c08BBE509DFD6FF0D--
