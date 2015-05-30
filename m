From: Grant Zhang <gzhang@fastly.com>
Subject: Re: Recurring trace from tcp_fragment()
Date: Sat, 30 May 2015 11:52:55 -0700
Message-ID: <904FADEB-C1EB-4384-BA47-0EB0273AFB71@fastly.com>
References: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com> <CADVnQyngTDVYMhmQq=pjS3LrdQ+HXyizujiOkmgXxTjQ0QKH8A@mail.gmail.com> <5E30A40E-EC6C-4D37-AB49-04BF40EEFBFC@fastly.com> <CADVnQy=rwKG_ddduixcee1D4HaaSBBk=X=2Htmdow0k6Cbxhzg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: multipart/mixed; boundary="Apple-Mail=_DFE9B9CC-9214-47AC-A904-640A5F3039DC"
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32980 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbbE3Sw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 14:52:57 -0400
Received: by padj3 with SMTP id j3so14451651pad.0
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 11:52:56 -0700 (PDT)
In-Reply-To: <CADVnQy=rwKG_ddduixcee1D4HaaSBBk=X=2Htmdow0k6Cbxhzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_DFE9B9CC-9214-47AC-A904-640A5F3039DC
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

Thank you Neal. Most likely I will test the patch on Monday and report
back the result.

As for the TcpExtTCPSACKReneging counter, attached is the captured
counter value on a 1-second interval for 10 minutes.

Thanks,

Grant



--Apple-Mail=_DFE9B9CC-9214-47AC-A904-640A5F3039DC
Content-Disposition: attachment;
	filename=reneg.log
Content-Type: application/octet-stream;
	name="reneg.log"
Content-Transfer-Encoding: 7bit

TcpExtTCPSACKReneging           3029149            0.0
TcpExtTCPSACKReneging           3029149            0.0
TcpExtTCPSACKReneging           3029150            0.0
TcpExtTCPSACKReneging           3029151            0.0
TcpExtTCPSACKReneging           3029151            0.0
TcpExtTCPSACKReneging           3029152            0.0
TcpExtTCPSACKReneging           3029152            0.0
TcpExtTCPSACKReneging           3029152            0.0
TcpExtTCPSACKReneging           3029155            0.0
TcpExtTCPSACKReneging           3029155            0.0
TcpExtTCPSACKReneging           3029156            0.0
TcpExtTCPSACKReneging           3029157            0.0
TcpExtTCPSACKReneging           3029157            0.0
TcpExtTCPSACKReneging           3029159            0.0
TcpExtTCPSACKReneging           3029160            0.0
TcpExtTCPSACKReneging           3029160            0.0
TcpExtTCPSACKReneging           3029160            0.0
TcpExtTCPSACKReneging           3029160            0.0
TcpExtTCPSACKReneging           3029160            0.0
TcpExtTCPSACKReneging           3029160            0.0
TcpExtTCPSACKReneging           3029160            0.0
TcpExtTCPSACKReneging           3029161            0.0
TcpExtTCPSACKReneging           3029164            0.0
TcpExtTCPSACKReneging           3029165            0.0
TcpExtTCPSACKReneging           3029166            0.0
TcpExtTCPSACKReneging           3029166            0.0
TcpExtTCPSACKReneging           3029168            0.0
TcpExtTCPSACKReneging           3029168            0.0
TcpExtTCPSACKReneging           3029169            0.0
TcpExtTCPSACKReneging           3029169            0.0
TcpExtTCPSACKReneging           3029170            0.0
TcpExtTCPSACKReneging           3029170            0.0
TcpExtTCPSACKReneging           3029172            0.0
TcpExtTCPSACKReneging           3029172            0.0
TcpExtTCPSACKReneging           3029173            0.0
TcpExtTCPSACKReneging           3029173            0.0
TcpExtTCPSACKReneging           3029173            0.0
TcpExtTCPSACKReneging           3029173            0.0
TcpExtTCPSACKReneging           3029177            0.0
TcpExtTCPSACKReneging           3029179            0.0
TcpExtTCPSACKReneging           3029179            0.0
TcpExtTCPSACKReneging           3029181            0.0
TcpExtTCPSACKReneging           3029182            0.0
TcpExtTCPSACKReneging           3029182            0.0
TcpExtTCPSACKReneging           3029185            0.0
TcpExtTCPSACKReneging           3029185            0.0
TcpExtTCPSACKReneging           3029185            0.0
TcpExtTCPSACKReneging           3029186            0.0
TcpExtTCPSACKReneging           3029186            0.0
TcpExtTCPSACKReneging           3029186            0.0
TcpExtTCPSACKReneging           3029187            0.0
TcpExtTCPSACKReneging           3029187            0.0
TcpExtTCPSACKReneging           3029190            0.0
TcpExtTCPSACKReneging           3029190            0.0
TcpExtTCPSACKReneging           3029191            0.0
TcpExtTCPSACKReneging           3029192            0.0
TcpExtTCPSACKReneging           3029194            0.0
TcpExtTCPSACKReneging           3029194            0.0
TcpExtTCPSACKReneging           3029195            0.0
TcpExtTCPSACKReneging           3029198            0.0
TcpExtTCPSACKReneging           3029199            0.0
TcpExtTCPSACKReneging           3029204            0.0
TcpExtTCPSACKReneging           3029208            0.0
TcpExtTCPSACKReneging           3029211            0.0
TcpExtTCPSACKReneging           3029214            0.0
TcpExtTCPSACKReneging           3029219            0.0
TcpExtTCPSACKReneging           3029226            0.0
TcpExtTCPSACKReneging           3029230            0.0
TcpExtTCPSACKReneging           3029233            0.0
TcpExtTCPSACKReneging           3029237            0.0
TcpExtTCPSACKReneging           3029240            0.0
TcpExtTCPSACKReneging           3029243            0.0
TcpExtTCPSACKReneging           3029243            0.0
TcpExtTCPSACKReneging           3029244            0.0
TcpExtTCPSACKReneging           3029246            0.0
TcpExtTCPSACKReneging           3029247            0.0
TcpExtTCPSACKReneging           3029248            0.0
TcpExtTCPSACKReneging           3029252            0.0
TcpExtTCPSACKReneging           3029252            0.0
TcpExtTCPSACKReneging           3029252            0.0
TcpExtTCPSACKReneging           3029253            0.0
TcpExtTCPSACKReneging           3029255            0.0
TcpExtTCPSACKReneging           3029256            0.0
TcpExtTCPSACKReneging           3029257            0.0
TcpExtTCPSACKReneging           3029258            0.0
TcpExtTCPSACKReneging           3029259            0.0
TcpExtTCPSACKReneging           3029259            0.0
TcpExtTCPSACKReneging           3029259            0.0
TcpExtTCPSACKReneging           3029259            0.0
TcpExtTCPSACKReneging           3029259            0.0
TcpExtTCPSACKReneging           3029259            0.0
TcpExtTCPSACKReneging           3029259            0.0
TcpExtTCPSACKReneging           3029261            0.0
TcpExtTCPSACKReneging           3029261            0.0
TcpExtTCPSACKReneging           3029263            0.0
TcpExtTCPSACKReneging           3029264            0.0
TcpExtTCPSACKReneging           3029265            0.0
TcpExtTCPSACKReneging           3029265            0.0
TcpExtTCPSACKReneging           3029267            0.0
TcpExtTCPSACKReneging           3029268            0.0
TcpExtTCPSACKReneging           3029271            0.0
TcpExtTCPSACKReneging           3029271            0.0
TcpExtTCPSACKReneging           3029273            0.0
TcpExtTCPSACKReneging           3029273            0.0
TcpExtTCPSACKReneging           3029274            0.0
TcpExtTCPSACKReneging           3029275            0.0
TcpExtTCPSACKReneging           3029275            0.0
TcpExtTCPSACKReneging           3029275            0.0
TcpExtTCPSACKReneging           3029275            0.0
TcpExtTCPSACKReneging           3029275            0.0
TcpExtTCPSACKReneging           3029276            0.0
TcpExtTCPSACKReneging           3029276            0.0
TcpExtTCPSACKReneging           3029277            0.0
TcpExtTCPSACKReneging           3029277            0.0
TcpExtTCPSACKReneging           3029277            0.0
TcpExtTCPSACKReneging           3029277            0.0
TcpExtTCPSACKReneging           3029278            0.0
TcpExtTCPSACKReneging           3029278            0.0
TcpExtTCPSACKReneging           3029279            0.0
TcpExtTCPSACKReneging           3029280            0.0
TcpExtTCPSACKReneging           3029281            0.0
TcpExtTCPSACKReneging           3029281            0.0
TcpExtTCPSACKReneging           3029281            0.0
TcpExtTCPSACKReneging           3029282            0.0
TcpExtTCPSACKReneging           3029284            0.0
TcpExtTCPSACKReneging           3029285            0.0
TcpExtTCPSACKReneging           3029287            0.0
TcpExtTCPSACKReneging           3029287            0.0
TcpExtTCPSACKReneging           3029288            0.0
TcpExtTCPSACKReneging           3029288            0.0
TcpExtTCPSACKReneging           3029288            0.0
TcpExtTCPSACKReneging           3029289            0.0
TcpExtTCPSACKReneging           3029290            0.0
TcpExtTCPSACKReneging           3029294            0.0
TcpExtTCPSACKReneging           3029294            0.0
TcpExtTCPSACKReneging           3029295            0.0
TcpExtTCPSACKReneging           3029297            0.0
TcpExtTCPSACKReneging           3029298            0.0
TcpExtTCPSACKReneging           3029299            0.0
TcpExtTCPSACKReneging           3029301            0.0
TcpExtTCPSACKReneging           3029303            0.0
TcpExtTCPSACKReneging           3029306            0.0
TcpExtTCPSACKReneging           3029308            0.0
TcpExtTCPSACKReneging           3029309            0.0
TcpExtTCPSACKReneging           3029310            0.0
TcpExtTCPSACKReneging           3029313            0.0
TcpExtTCPSACKReneging           3029314            0.0
TcpExtTCPSACKReneging           3029315            0.0
TcpExtTCPSACKReneging           3029315            0.0
TcpExtTCPSACKReneging           3029318            0.0
TcpExtTCPSACKReneging           3029318            0.0
TcpExtTCPSACKReneging           3029319            0.0
TcpExtTCPSACKReneging           3029320            0.0
TcpExtTCPSACKReneging           3029321            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029324            0.0
TcpExtTCPSACKReneging           3029325            0.0
TcpExtTCPSACKReneging           3029327            0.0
TcpExtTCPSACKReneging           3029330            0.0
TcpExtTCPSACKReneging           3029332            0.0
TcpExtTCPSACKReneging           3029332            0.0
TcpExtTCPSACKReneging           3029332            0.0
TcpExtTCPSACKReneging           3029332            0.0
TcpExtTCPSACKReneging           3029334            0.0
TcpExtTCPSACKReneging           3029338            0.0
TcpExtTCPSACKReneging           3029341            0.0
TcpExtTCPSACKReneging           3029343            0.0
TcpExtTCPSACKReneging           3029347            0.0
TcpExtTCPSACKReneging           3029350            0.0
TcpExtTCPSACKReneging           3029353            0.0
TcpExtTCPSACKReneging           3029355            0.0
TcpExtTCPSACKReneging           3029355            0.0
TcpExtTCPSACKReneging           3029357            0.0
TcpExtTCPSACKReneging           3029357            0.0
TcpExtTCPSACKReneging           3029357            0.0
TcpExtTCPSACKReneging           3029358            0.0
TcpExtTCPSACKReneging           3029358            0.0
TcpExtTCPSACKReneging           3029361            0.0
TcpExtTCPSACKReneging           3029365            0.0
TcpExtTCPSACKReneging           3029366            0.0
TcpExtTCPSACKReneging           3029367            0.0
TcpExtTCPSACKReneging           3029369            0.0
TcpExtTCPSACKReneging           3029369            0.0
TcpExtTCPSACKReneging           3029369            0.0
TcpExtTCPSACKReneging           3029371            0.0
TcpExtTCPSACKReneging           3029372            0.0
TcpExtTCPSACKReneging           3029375            0.0
TcpExtTCPSACKReneging           3029377            0.0
TcpExtTCPSACKReneging           3029377            0.0
TcpExtTCPSACKReneging           3029378            0.0
TcpExtTCPSACKReneging           3029379            0.0
TcpExtTCPSACKReneging           3029381            0.0
TcpExtTCPSACKReneging           3029384            0.0
TcpExtTCPSACKReneging           3029385            0.0
TcpExtTCPSACKReneging           3029388            0.0
TcpExtTCPSACKReneging           3029390            0.0
TcpExtTCPSACKReneging           3029390            0.0
TcpExtTCPSACKReneging           3029393            0.0
TcpExtTCPSACKReneging           3029395            0.0
TcpExtTCPSACKReneging           3029395            0.0
TcpExtTCPSACKReneging           3029397            0.0
TcpExtTCPSACKReneging           3029397            0.0
TcpExtTCPSACKReneging           3029397            0.0
TcpExtTCPSACKReneging           3029397            0.0
TcpExtTCPSACKReneging           3029399            0.0
TcpExtTCPSACKReneging           3029404            0.0
TcpExtTCPSACKReneging           3029405            0.0
TcpExtTCPSACKReneging           3029405            0.0
TcpExtTCPSACKReneging           3029406            0.0
TcpExtTCPSACKReneging           3029408            0.0
TcpExtTCPSACKReneging           3029410            0.0
TcpExtTCPSACKReneging           3029411            0.0
TcpExtTCPSACKReneging           3029413            0.0
TcpExtTCPSACKReneging           3029413            0.0
TcpExtTCPSACKReneging           3029415            0.0
TcpExtTCPSACKReneging           3029417            0.0
TcpExtTCPSACKReneging           3029418            0.0
TcpExtTCPSACKReneging           3029418            0.0
TcpExtTCPSACKReneging           3029421            0.0
TcpExtTCPSACKReneging           3029423            0.0
TcpExtTCPSACKReneging           3029424            0.0
TcpExtTCPSACKReneging           3029425            0.0
TcpExtTCPSACKReneging           3029425            0.0
TcpExtTCPSACKReneging           3029426            0.0
TcpExtTCPSACKReneging           3029426            0.0
TcpExtTCPSACKReneging           3029426            0.0
TcpExtTCPSACKReneging           3029427            0.0
TcpExtTCPSACKReneging           3029427            0.0
TcpExtTCPSACKReneging           3029428            0.0
TcpExtTCPSACKReneging           3029429            0.0
TcpExtTCPSACKReneging           3029430            0.0
TcpExtTCPSACKReneging           3029431            0.0
TcpExtTCPSACKReneging           3029431            0.0
TcpExtTCPSACKReneging           3029433            0.0
TcpExtTCPSACKReneging           3029434            0.0
TcpExtTCPSACKReneging           3029437            0.0
TcpExtTCPSACKReneging           3029438            0.0
TcpExtTCPSACKReneging           3029438            0.0
TcpExtTCPSACKReneging           3029438            0.0
TcpExtTCPSACKReneging           3029439            0.0
TcpExtTCPSACKReneging           3029441            0.0
TcpExtTCPSACKReneging           3029441            0.0
TcpExtTCPSACKReneging           3029443            0.0
TcpExtTCPSACKReneging           3029443            0.0
TcpExtTCPSACKReneging           3029444            0.0
TcpExtTCPSACKReneging           3029445            0.0
TcpExtTCPSACKReneging           3029446            0.0
TcpExtTCPSACKReneging           3029448            0.0
TcpExtTCPSACKReneging           3029449            0.0
TcpExtTCPSACKReneging           3029450            0.0
TcpExtTCPSACKReneging           3029450            0.0
TcpExtTCPSACKReneging           3029452            0.0
TcpExtTCPSACKReneging           3029453            0.0
TcpExtTCPSACKReneging           3029453            0.0
TcpExtTCPSACKReneging           3029455            0.0
TcpExtTCPSACKReneging           3029455            0.0
TcpExtTCPSACKReneging           3029457            0.0
TcpExtTCPSACKReneging           3029458            0.0
TcpExtTCPSACKReneging           3029460            0.0
TcpExtTCPSACKReneging           3029462            0.0
TcpExtTCPSACKReneging           3029462            0.0
TcpExtTCPSACKReneging           3029465            0.0
TcpExtTCPSACKReneging           3029473            0.0
TcpExtTCPSACKReneging           3029483            0.0
TcpExtTCPSACKReneging           3029485            0.0
TcpExtTCPSACKReneging           3029485            0.0
TcpExtTCPSACKReneging           3029486            0.0
TcpExtTCPSACKReneging           3029486            0.0
TcpExtTCPSACKReneging           3029487            0.0
TcpExtTCPSACKReneging           3029487            0.0
TcpExtTCPSACKReneging           3029488            0.0
TcpExtTCPSACKReneging           3029493            0.0
TcpExtTCPSACKReneging           3029495            0.0
TcpExtTCPSACKReneging           3029496            0.0
TcpExtTCPSACKReneging           3029497            0.0
TcpExtTCPSACKReneging           3029499            0.0
TcpExtTCPSACKReneging           3029501            0.0
TcpExtTCPSACKReneging           3029504            0.0
TcpExtTCPSACKReneging           3029505            0.0
TcpExtTCPSACKReneging           3029506            0.0
TcpExtTCPSACKReneging           3029511            0.0
TcpExtTCPSACKReneging           3029512            0.0
TcpExtTCPSACKReneging           3029514            0.0
TcpExtTCPSACKReneging           3029515            0.0
TcpExtTCPSACKReneging           3029517            0.0
TcpExtTCPSACKReneging           3029521            0.0
TcpExtTCPSACKReneging           3029525            0.0
TcpExtTCPSACKReneging           3029528            0.0
TcpExtTCPSACKReneging           3029530            0.0
TcpExtTCPSACKReneging           3029532            0.0
TcpExtTCPSACKReneging           3029534            0.0
TcpExtTCPSACKReneging           3029534            0.0
TcpExtTCPSACKReneging           3029536            0.0
TcpExtTCPSACKReneging           3029537            0.0
TcpExtTCPSACKReneging           3029539            0.0
TcpExtTCPSACKReneging           3029544            0.0
TcpExtTCPSACKReneging           3029547            0.0
TcpExtTCPSACKReneging           3029548            0.0
TcpExtTCPSACKReneging           3029553            0.0
TcpExtTCPSACKReneging           3029554            0.0
TcpExtTCPSACKReneging           3029557            0.0
TcpExtTCPSACKReneging           3029557            0.0
TcpExtTCPSACKReneging           3029558            0.0
TcpExtTCPSACKReneging           3029560            0.0
TcpExtTCPSACKReneging           3029560            0.0
TcpExtTCPSACKReneging           3029562            0.0
TcpExtTCPSACKReneging           3029562            0.0
TcpExtTCPSACKReneging           3029562            0.0
TcpExtTCPSACKReneging           3029563            0.0
TcpExtTCPSACKReneging           3029564            0.0
TcpExtTCPSACKReneging           3029565            0.0
TcpExtTCPSACKReneging           3029567            0.0
TcpExtTCPSACKReneging           3029568            0.0
TcpExtTCPSACKReneging           3029575            0.0
TcpExtTCPSACKReneging           3029575            0.0
TcpExtTCPSACKReneging           3029575            0.0
TcpExtTCPSACKReneging           3029575            0.0
TcpExtTCPSACKReneging           3029575            0.0
TcpExtTCPSACKReneging           3029575            0.0
TcpExtTCPSACKReneging           3029576            0.0
TcpExtTCPSACKReneging           3029577            0.0
TcpExtTCPSACKReneging           3029580            0.0
TcpExtTCPSACKReneging           3029581            0.0
TcpExtTCPSACKReneging           3029581            0.0
TcpExtTCPSACKReneging           3029581            0.0
TcpExtTCPSACKReneging           3029582            0.0
TcpExtTCPSACKReneging           3029582            0.0
TcpExtTCPSACKReneging           3029582            0.0
TcpExtTCPSACKReneging           3029582            0.0
TcpExtTCPSACKReneging           3029583            0.0
TcpExtTCPSACKReneging           3029584            0.0
TcpExtTCPSACKReneging           3029584            0.0
TcpExtTCPSACKReneging           3029584            0.0
TcpExtTCPSACKReneging           3029586            0.0
TcpExtTCPSACKReneging           3029587            0.0
TcpExtTCPSACKReneging           3029588            0.0
TcpExtTCPSACKReneging           3029589            0.0
TcpExtTCPSACKReneging           3029591            0.0
TcpExtTCPSACKReneging           3029592            0.0
TcpExtTCPSACKReneging           3029592            0.0
TcpExtTCPSACKReneging           3029592            0.0
TcpExtTCPSACKReneging           3029594            0.0
TcpExtTCPSACKReneging           3029596            0.0
TcpExtTCPSACKReneging           3029597            0.0
TcpExtTCPSACKReneging           3029598            0.0
TcpExtTCPSACKReneging           3029598            0.0
TcpExtTCPSACKReneging           3029598            0.0
TcpExtTCPSACKReneging           3029598            0.0
TcpExtTCPSACKReneging           3029598            0.0
TcpExtTCPSACKReneging           3029601            0.0
TcpExtTCPSACKReneging           3029604            0.0
TcpExtTCPSACKReneging           3029605            0.0
TcpExtTCPSACKReneging           3029605            0.0
TcpExtTCPSACKReneging           3029605            0.0
TcpExtTCPSACKReneging           3029606            0.0
TcpExtTCPSACKReneging           3029607            0.0
TcpExtTCPSACKReneging           3029609            0.0
TcpExtTCPSACKReneging           3029609            0.0
TcpExtTCPSACKReneging           3029610            0.0
TcpExtTCPSACKReneging           3029610            0.0
TcpExtTCPSACKReneging           3029612            0.0
TcpExtTCPSACKReneging           3029612            0.0
TcpExtTCPSACKReneging           3029612            0.0
TcpExtTCPSACKReneging           3029612            0.0
TcpExtTCPSACKReneging           3029613            0.0
TcpExtTCPSACKReneging           3029613            0.0
TcpExtTCPSACKReneging           3029614            0.0
TcpExtTCPSACKReneging           3029615            0.0
TcpExtTCPSACKReneging           3029617            0.0
TcpExtTCPSACKReneging           3029617            0.0
TcpExtTCPSACKReneging           3029618            0.0
TcpExtTCPSACKReneging           3029620            0.0
TcpExtTCPSACKReneging           3029620            0.0
TcpExtTCPSACKReneging           3029621            0.0
TcpExtTCPSACKReneging           3029625            0.0
TcpExtTCPSACKReneging           3029625            0.0
TcpExtTCPSACKReneging           3029625            0.0
TcpExtTCPSACKReneging           3029625            0.0
TcpExtTCPSACKReneging           3029626            0.0
TcpExtTCPSACKReneging           3029627            0.0
TcpExtTCPSACKReneging           3029629            0.0
TcpExtTCPSACKReneging           3029631            0.0
TcpExtTCPSACKReneging           3029632            0.0
TcpExtTCPSACKReneging           3029633            0.0
TcpExtTCPSACKReneging           3029633            0.0
TcpExtTCPSACKReneging           3029634            0.0
TcpExtTCPSACKReneging           3029634            0.0
TcpExtTCPSACKReneging           3029635            0.0
TcpExtTCPSACKReneging           3029643            0.0
TcpExtTCPSACKReneging           3029645            0.0
TcpExtTCPSACKReneging           3029646            0.0
TcpExtTCPSACKReneging           3029646            0.0
TcpExtTCPSACKReneging           3029647            0.0
TcpExtTCPSACKReneging           3029656            0.0
TcpExtTCPSACKReneging           3029664            0.0
TcpExtTCPSACKReneging           3029667            0.0
TcpExtTCPSACKReneging           3029669            0.0
TcpExtTCPSACKReneging           3029671            0.0
TcpExtTCPSACKReneging           3029673            0.0
TcpExtTCPSACKReneging           3029678            0.0
TcpExtTCPSACKReneging           3029680            0.0
TcpExtTCPSACKReneging           3029683            0.0
TcpExtTCPSACKReneging           3029683            0.0
TcpExtTCPSACKReneging           3029686            0.0
TcpExtTCPSACKReneging           3029691            0.0
TcpExtTCPSACKReneging           3029694            0.0
TcpExtTCPSACKReneging           3029699            0.0
TcpExtTCPSACKReneging           3029705            0.0
TcpExtTCPSACKReneging           3029706            0.0
TcpExtTCPSACKReneging           3029708            0.0
TcpExtTCPSACKReneging           3029710            0.0
TcpExtTCPSACKReneging           3029712            0.0
TcpExtTCPSACKReneging           3029713            0.0
TcpExtTCPSACKReneging           3029718            0.0
TcpExtTCPSACKReneging           3029720            0.0
TcpExtTCPSACKReneging           3029722            0.0
TcpExtTCPSACKReneging           3029723            0.0
TcpExtTCPSACKReneging           3029724            0.0
TcpExtTCPSACKReneging           3029726            0.0
TcpExtTCPSACKReneging           3029730            0.0
TcpExtTCPSACKReneging           3029732            0.0
TcpExtTCPSACKReneging           3029736            0.0
TcpExtTCPSACKReneging           3029738            0.0
TcpExtTCPSACKReneging           3029745            0.0
TcpExtTCPSACKReneging           3029745            0.0
TcpExtTCPSACKReneging           3029745            0.0
TcpExtTCPSACKReneging           3029746            0.0
TcpExtTCPSACKReneging           3029747            0.0
TcpExtTCPSACKReneging           3029747            0.0
TcpExtTCPSACKReneging           3029748            0.0
TcpExtTCPSACKReneging           3029753            0.0
TcpExtTCPSACKReneging           3029753            0.0
TcpExtTCPSACKReneging           3029753            0.0
TcpExtTCPSACKReneging           3029753            0.0
TcpExtTCPSACKReneging           3029754            0.0
TcpExtTCPSACKReneging           3029755            0.0
TcpExtTCPSACKReneging           3029756            0.0
TcpExtTCPSACKReneging           3029758            0.0
TcpExtTCPSACKReneging           3029759            0.0
TcpExtTCPSACKReneging           3029762            0.0
TcpExtTCPSACKReneging           3029762            0.0
TcpExtTCPSACKReneging           3029762            0.0
TcpExtTCPSACKReneging           3029764            0.0
TcpExtTCPSACKReneging           3029764            0.0
TcpExtTCPSACKReneging           3029766            0.0
TcpExtTCPSACKReneging           3029768            0.0
TcpExtTCPSACKReneging           3029771            0.0
TcpExtTCPSACKReneging           3029772            0.0
TcpExtTCPSACKReneging           3029773            0.0
TcpExtTCPSACKReneging           3029776            0.0
TcpExtTCPSACKReneging           3029779            0.0
TcpExtTCPSACKReneging           3029780            0.0
TcpExtTCPSACKReneging           3029782            0.0
TcpExtTCPSACKReneging           3029786            0.0
TcpExtTCPSACKReneging           3029788            0.0
TcpExtTCPSACKReneging           3029791            0.0
TcpExtTCPSACKReneging           3029794            0.0
TcpExtTCPSACKReneging           3029795            0.0
TcpExtTCPSACKReneging           3029796            0.0
TcpExtTCPSACKReneging           3029798            0.0
TcpExtTCPSACKReneging           3029800            0.0
TcpExtTCPSACKReneging           3029802            0.0
TcpExtTCPSACKReneging           3029802            0.0
TcpExtTCPSACKReneging           3029804            0.0
TcpExtTCPSACKReneging           3029804            0.0
TcpExtTCPSACKReneging           3029807            0.0
TcpExtTCPSACKReneging           3029810            0.0
TcpExtTCPSACKReneging           3029810            0.0
TcpExtTCPSACKReneging           3029813            0.0
TcpExtTCPSACKReneging           3029818            0.0
TcpExtTCPSACKReneging           3029819            0.0
TcpExtTCPSACKReneging           3029824            0.0
TcpExtTCPSACKReneging           3029826            0.0
TcpExtTCPSACKReneging           3029827            0.0
TcpExtTCPSACKReneging           3029832            0.0
TcpExtTCPSACKReneging           3029840            0.0
TcpExtTCPSACKReneging           3029842            0.0
TcpExtTCPSACKReneging           3029843            0.0
TcpExtTCPSACKReneging           3029843            0.0
TcpExtTCPSACKReneging           3029845            0.0
TcpExtTCPSACKReneging           3029848            0.0
TcpExtTCPSACKReneging           3029849            0.0
TcpExtTCPSACKReneging           3029852            0.0
TcpExtTCPSACKReneging           3029856            0.0
TcpExtTCPSACKReneging           3029859            0.0
TcpExtTCPSACKReneging           3029860            0.0
TcpExtTCPSACKReneging           3029862            0.0
TcpExtTCPSACKReneging           3029863            0.0
TcpExtTCPSACKReneging           3029865            0.0
TcpExtTCPSACKReneging           3029867            0.0
TcpExtTCPSACKReneging           3029868            0.0
TcpExtTCPSACKReneging           3029868            0.0
TcpExtTCPSACKReneging           3029869            0.0
TcpExtTCPSACKReneging           3029870            0.0
TcpExtTCPSACKReneging           3029871            0.0
TcpExtTCPSACKReneging           3029875            0.0
TcpExtTCPSACKReneging           3029877            0.0
TcpExtTCPSACKReneging           3029879            0.0
TcpExtTCPSACKReneging           3029882            0.0
TcpExtTCPSACKReneging           3029885            0.0
TcpExtTCPSACKReneging           3029887            0.0
TcpExtTCPSACKReneging           3029893            0.0
TcpExtTCPSACKReneging           3029895            0.0
TcpExtTCPSACKReneging           3029897            0.0
TcpExtTCPSACKReneging           3029898            0.0
TcpExtTCPSACKReneging           3029899            0.0
TcpExtTCPSACKReneging           3029899            0.0
TcpExtTCPSACKReneging           3029902            0.0
TcpExtTCPSACKReneging           3029902            0.0
TcpExtTCPSACKReneging           3029905            0.0
TcpExtTCPSACKReneging           3029907            0.0
TcpExtTCPSACKReneging           3029907            0.0
TcpExtTCPSACKReneging           3029908            0.0
TcpExtTCPSACKReneging           3029910            0.0
TcpExtTCPSACKReneging           3029911            0.0
TcpExtTCPSACKReneging           3029913            0.0
TcpExtTCPSACKReneging           3029915            0.0
TcpExtTCPSACKReneging           3029919            0.0
TcpExtTCPSACKReneging           3029922            0.0
TcpExtTCPSACKReneging           3029924            0.0
TcpExtTCPSACKReneging           3029925            0.0
TcpExtTCPSACKReneging           3029926            0.0
TcpExtTCPSACKReneging           3029927            0.0
TcpExtTCPSACKReneging           3029930            0.0
TcpExtTCPSACKReneging           3029933            0.0
TcpExtTCPSACKReneging           3029934            0.0
TcpExtTCPSACKReneging           3029934            0.0
TcpExtTCPSACKReneging           3029936            0.0
TcpExtTCPSACKReneging           3029937            0.0
TcpExtTCPSACKReneging           3029938            0.0
TcpExtTCPSACKReneging           3029939            0.0
TcpExtTCPSACKReneging           3029939            0.0
TcpExtTCPSACKReneging           3029940            0.0
TcpExtTCPSACKReneging           3029940            0.0
TcpExtTCPSACKReneging           3029940            0.0
TcpExtTCPSACKReneging           3029940            0.0
TcpExtTCPSACKReneging           3029940            0.0
TcpExtTCPSACKReneging           3029941            0.0
TcpExtTCPSACKReneging           3029941            0.0
TcpExtTCPSACKReneging           3029941            0.0
TcpExtTCPSACKReneging           3029942            0.0
TcpExtTCPSACKReneging           3029943            0.0
TcpExtTCPSACKReneging           3029944            0.0
TcpExtTCPSACKReneging           3029944            0.0
TcpExtTCPSACKReneging           3029945            0.0
TcpExtTCPSACKReneging           3029946            0.0
TcpExtTCPSACKReneging           3029946            0.0
TcpExtTCPSACKReneging           3029948            0.0
TcpExtTCPSACKReneging           3029950            0.0
TcpExtTCPSACKReneging           3029950            0.0
TcpExtTCPSACKReneging           3029950            0.0
TcpExtTCPSACKReneging           3029950            0.0
TcpExtTCPSACKReneging           3029951            0.0
TcpExtTCPSACKReneging           3029951            0.0
TcpExtTCPSACKReneging           3029954            0.0
TcpExtTCPSACKReneging           3029957            0.0
TcpExtTCPSACKReneging           3029958            0.0
TcpExtTCPSACKReneging           3029959            0.0
TcpExtTCPSACKReneging           3029960            0.0
TcpExtTCPSACKReneging           3029960            0.0
TcpExtTCPSACKReneging           3029961            0.0
TcpExtTCPSACKReneging           3029963            0.0
TcpExtTCPSACKReneging           3029965            0.0
TcpExtTCPSACKReneging           3029967            0.0
TcpExtTCPSACKReneging           3029968            0.0
TcpExtTCPSACKReneging           3029969            0.0
TcpExtTCPSACKReneging           3029970            0.0
TcpExtTCPSACKReneging           3029971            0.0
TcpExtTCPSACKReneging           3029972            0.0
TcpExtTCPSACKReneging           3029972            0.0
TcpExtTCPSACKReneging           3029973            0.0
TcpExtTCPSACKReneging           3029975            0.0
TcpExtTCPSACKReneging           3029975            0.0
TcpExtTCPSACKReneging           3029976            0.0
TcpExtTCPSACKReneging           3029976            0.0
TcpExtTCPSACKReneging           3029977            0.0
TcpExtTCPSACKReneging           3029977            0.0
TcpExtTCPSACKReneging           3029977            0.0
TcpExtTCPSACKReneging           3029978            0.0
TcpExtTCPSACKReneging           3029978            0.0
TcpExtTCPSACKReneging           3029981            0.0
TcpExtTCPSACKReneging           3029981            0.0
TcpExtTCPSACKReneging           3029981            0.0
TcpExtTCPSACKReneging           3029982            0.0
TcpExtTCPSACKReneging           3029984            0.0
TcpExtTCPSACKReneging           3029986            0.0
TcpExtTCPSACKReneging           3029988            0.0
TcpExtTCPSACKReneging           3029990            0.0
TcpExtTCPSACKReneging           3029992            0.0
TcpExtTCPSACKReneging           3029993            0.0
TcpExtTCPSACKReneging           3029994            0.0
TcpExtTCPSACKReneging           3029996            0.0
TcpExtTCPSACKReneging           3029997            0.0
TcpExtTCPSACKReneging           3029998            0.0
TcpExtTCPSACKReneging           3029998            0.0

--Apple-Mail=_DFE9B9CC-9214-47AC-A904-640A5F3039DC
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii





> On May 30, 2015, at 10:29 AM, Neal Cardwell <ncardwell@google.com> wrote:
> 
> On Fri, May 29, 2015 at 3:53 PM, Grant Zhang <gzhang@fastly.com> wrote:
>> Hi Neal,
>> 
>> I will be more happy to test the patch. Please send it my way.
> 
> Great. Thank you so much for being willing to do this. Attached is a
> patch for testing. I generated it and tested it relative to Linux
> v3.14.39, since your stack trace seemed to suggest that you were
> seeing this on some variant of v3.14.39. (Newer kernels would need a
> slightly different patch, since the reneging code path has changed a
> little since 3.14.)
> 
> Can you please try it out and see if it makes that warning go away?
> 
> Also, I would be interested in seeing the value of your
> TcpExtTCPSACKReneging counter, and some sense of how fast that value
> is increasing, on a machine that's seeing this issue:
>  nstat -z -a | grep Reneg
> 
> Thanks!
> 
> neal
> <0001-RFC-for-tests-on-v3.14.39-tcp-resegment-skbs-that-we.patch>


--Apple-Mail=_DFE9B9CC-9214-47AC-A904-640A5F3039DC--
