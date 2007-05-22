From: Pasakorn Tiwatthanont <pasakorn.tiwatthanont@nectec.or.th>
Subject: Re: Re: rstp for 2.4 kernel: port state keeps changing
Date: Tue, 22 May 2007 08:05:35 +0700
Message-ID: <465241DF.4090009@nectec.or.th>
References: <OF2B235CAE.4C560998-ON8525729F.005E1121-8525729F.005E4D58@smsc.com>
Reply-To: pasakorn.tiwatthanont@nectec.or.th
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6795288697692551623=="
Cc: bridge-bounces@lists.osdl.org, bridge@linux-foundation.org,
        netdev@vger.kernel.org
To: Marc.Obbad@smsc.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <OF2B235CAE.4C560998-ON8525729F.005E1121-8525729F.005E4D58@smsc.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============6795288697692551623==
Content-Type: multipart/alternative;
	boundary="------------060702030204070500010505"

This is a multi-part message in MIME format.
--------------060702030204070500010505
Content-Type: text/plain; charset=TIS-620
Content-Transfer-Encoding: 7bit

Dear,
    Could I use this patch with main stream, Linux x86 for PC ?

Best regards,
Pasakorn

Marc.Obbad@smsc.com wrote:
> For me, I ma building for Embedded platform.
> Go to Directory where the Makefile is and do this:
>
>
> make -C  $LINUX_DIR  SUBDIRS=WD  modules
> LINUX_DIR should point to LINUX directory
>
> LINUX_DIR=ome/swdev/PPC/linux/   as example
>
> -Marc.
>
>
>
>                                                                                                                         
>              Pasakorn Tiwatthanont                                                                                      
>              <ptiwatthanont@gmail.com>                                                                                  
>              Sent by:                                                                                                To 
>              bridge-bounces@lists.osdl.org               Marc Obbad/SMSC@SMSC                                           
>                                                                                                                      cc 
>                                                          bridge-bounces@lists.osdl.org, bridge@linux-foundation.org,    
>              03/15/2007 01:56 AM                         netdev@vger.kernel.org                                         
>                                                                                                                 Subject 
>                                                          Re: [Bridge] rstp for 2.4 kernel: port state keeps changing    
>                       Please respond to                                                                                 
>                    ptiwatthanont@gmail.com                                                                              
>                                                                                                                         
>                                                                                                                         
>                                                                                                                         
>                                                                                                                         
>
>
>
>
> Dear,    I tried to patch rstp-2.4.zip but I can not compile it.
> If don't take your time too much, please explain me how to use
> this patch files.
>
> Thank you very much
> iPAS
>
> Marc.Obbad@smsc.com wrote:
>       I have downloaded RSTP from this site:
>
>
>             http://developer.osdl.org/shemminger/prototypes/rstp-2.4.zip
>
>
>       -Marc
>
>
>
>
>
>
>                    Stephen Hemminger
>
>                    <shemminger@linux-foundation.org>
>
>                    Sent by:
>       To
>                    bridge-bounces@lists.osdl.org               Marc Obbad/SMSC@SMSC
>
>       cc
>                                                                netdev@vger.kernel.org, bridge@linux-foundation.org
>
>                    03/09/2007 01:55 PM
>       Subject
>                                                                Re: [Bridge] rstp for 2.4 kernel: port state keeps
>       changing
>
>
>
>
>
>
>
>
>
>
>       On Fri, 9 Mar 2007 12:24:40 -0500
>       Marc.Obbad@smsc.com wrote:
>
>
>             Hi,
>
>             I am using RSTP for 2.4 kernel.
>
>
>       RSTP is not in the mainline kernel tree. Please post the patch or a where the
>       source can be downloaded.
>
>       --
>       Stephen Hemminger <shemminger@linux-foundation.org>
>       _______________________________________________
>       Bridge mailing list
>       Bridge@lists.osdl.org
>       https://lists.osdl.org/mailman/listinfo/bridge
>
>
>       _______________________________________________
>       Bridge mailing list
>       Bridge@lists.osdl.org
>       https://lists.osdl.org/mailman/listinfo/bridge
>
>         _______________________________________________
>       Bridge mailing list
>       Bridge@lists.osdl.org
>       https://lists.osdl.org/mailman/listinfo/bridge
>
>
>
>   

--------------060702030204070500010505
Content-Type: text/html; charset=TIS-620
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp2.linux-foundation.org id l4MFCLWE019720

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content=3D"text/html;charset=3DTIS-620" http-equiv=3D"Content-Typ=
e">
</head>
<body bgcolor=3D"#ffffff" text=3D"#000000">
<font size=3D"-1">Dear,<br>
=A0=A0=A0 Could I use this patch with main stream, Linux x86 for PC ?<br>
<br>
Best regards,<br>
Pasakorn<br>
</font><br>
<a class=3D"moz-txt-link-abbreviated" href=3D"mailto:Marc.Obbad@smsc.com"=
>Marc.Obbad@smsc.com</a> wrote:
<blockquote
 cite=3D"mid:%3COF2B235CAE.4C560998-ON8525729F.005E1121-8525729F.005E4D58=
@smsc.com%3E"
 type=3D"cite">
  <pre wrap=3D"">For me, I ma building for Embedded platform.
Go to Directory where the Makefile is and do this:


make -C  $LINUX_DIR  SUBDIRS=3DWD  modules
LINUX_DIR should point to LINUX directory

LINUX_DIR=3Dome/swdev/PPC/linux/   as example

-Marc.



                                                                         =
                                              =20
             Pasakorn Tiwatthanont                                       =
                                              =20
             <a class=3D"moz-txt-link-rfc2396E" href=3D"mailto:ptiwatthan=
ont@gmail.com">&lt;ptiwatthanont@gmail.com&gt;</a>                       =
                                                          =20
             Sent by:                                                    =
                                            To=20
             <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:bridge-=
bounces@lists.osdl.org">bridge-bounces@lists.osdl.org</a>               M=
arc Obbad/SMSC@SMSC                                          =20
                                                                         =
                                            cc=20
                                                         <a class=3D"moz-=
txt-link-abbreviated" href=3D"mailto:bridge-bounces@lists.osdl.org">bridg=
e-bounces@lists.osdl.org</a>, <a class=3D"moz-txt-link-abbreviated" href=3D=
"mailto:bridge@linux-foundation.org">bridge@linux-foundation.org</a>,   =20
             03/15/2007 01:56 AM                         <a class=3D"moz-=
txt-link-abbreviated" href=3D"mailto:netdev@vger.kernel.org">netdev@vger.=
kernel.org</a>                                        =20
                                                                         =
                                       Subject=20
                                                         Re: [Bridge] rst=
p for 2.4 kernel: port state keeps changing   =20
                      Please respond to                                  =
                                              =20
                   <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:p=
tiwatthanont@gmail.com">ptiwatthanont@gmail.com</a>                      =
                                                       =20
                                                                         =
                                              =20
                                                                         =
                                              =20
                                                                         =
                                              =20
                                                                         =
                                              =20




Dear,=A0=A0=A0 I tried to patch rstp-2.4.zip but I can not compile it.
If don't take your time too much, please explain me how to use
this patch files.

Thank you very much
iPAS

<a class=3D"moz-txt-link-abbreviated" href=3D"mailto:Marc.Obbad@smsc.com"=
>Marc.Obbad@smsc.com</a> wrote:
      I have downloaded RSTP from this site:


            <a class=3D"moz-txt-link-freetext" href=3D"http://developer.o=
sdl.org/shemminger/prototypes/rstp-2.4.zip">http://developer.osdl.org/she=
mminger/prototypes/rstp-2.4.zip</a>


      -Marc






                   Stephen Hemminger

                   <a class=3D"moz-txt-link-rfc2396E" href=3D"mailto:shem=
minger@linux-foundation.org">&lt;shemminger@linux-foundation.org&gt;</a>

                   Sent by:
      To
                   <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:b=
ridge-bounces@lists.osdl.org">bridge-bounces@lists.osdl.org</a>          =
     Marc Obbad/SMSC@SMSC

      cc
                                                               <a class=3D=
"moz-txt-link-abbreviated" href=3D"mailto:netdev@vger.kernel.org">netdev@=
vger.kernel.org</a>, <a class=3D"moz-txt-link-abbreviated" href=3D"mailto=
:bridge@linux-foundation.org">bridge@linux-foundation.org</a>

                   03/09/2007 01:55 PM
      Subject
                                                               Re: [Bridg=
e] rstp for 2.4 kernel: port state keeps
      changing










      On Fri, 9 Mar 2007 12:24:40 -0500
      <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:Marc.Obbad@sms=
c.com">Marc.Obbad@smsc.com</a> wrote:


            Hi,

            I am using RSTP for 2.4 kernel.


      RSTP is not in the mainline kernel tree. Please post the patch or a=
 where the
      source can be downloaded.

      --
      Stephen Hemminger <a class=3D"moz-txt-link-rfc2396E" href=3D"mailto=
:shemminger@linux-foundation.org">&lt;shemminger@linux-foundation.org&gt;=
</a>
      _______________________________________________
      Bridge mailing list
      <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:Bridge@lists.o=
sdl.org">Bridge@lists.osdl.org</a>
      <a class=3D"moz-txt-link-freetext" href=3D"https://lists.osdl.org/m=
ailman/listinfo/bridge">https://lists.osdl.org/mailman/listinfo/bridge</a=
>


      _______________________________________________
      Bridge mailing list
      <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:Bridge@lists.o=
sdl.org">Bridge@lists.osdl.org</a>
      <a class=3D"moz-txt-link-freetext" href=3D"https://lists.osdl.org/m=
ailman/listinfo/bridge">https://lists.osdl.org/mailman/listinfo/bridge</a=
>

        _______________________________________________
      Bridge mailing list
      <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:Bridge@lists.o=
sdl.org">Bridge@lists.osdl.org</a>
      <a class=3D"moz-txt-link-freetext" href=3D"https://lists.osdl.org/m=
ailman/listinfo/bridge">https://lists.osdl.org/mailman/listinfo/bridge</a=
>



  </pre>
</blockquote>
</body>
</html>

--------------060702030204070500010505--

--===============6795288697692551623==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============6795288697692551623==--
