From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Fri, 12 Sep 2014 10:25:25 +0200
Message-ID: <1410510325.3817832.166646677.44FE4047@webmail.messagingengine.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
 <54078FBC.5050402@redhat.com>
 <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
 <1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
 <1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
 <1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAADnVQLh6qOD2epUq0S5P8RkUgZA38JNxeP40uBMScLHC2SsJg@mail.gmail.com>
 <CAHj3AVn8q-JS0Eq0QrfpBo-WfJ+-wXumhNoeDAdkPZC7LSeB5g@mail.gmail.com>
 <1409831412.23465.3.camel@localhost>
 <1409836154.26422.101.camel@edumazet-glaptop2.roam.corp.google.com>
 <1409838010.23465.16.camel@localhost>
 <1409839892.26422.115.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D174876B4@AcuExch.aculab.com>
 <1409841129.26422.117.camel@edumazet-glaptop2.roam.corp.google.com>
 <1409841233.23465.22.camel@localhost>
 <1409841347.26422.118.camel@edumazet-glaptop2.roam.corp.google.com>
 <1409841709.23465.25.camel@localhost>
 <CAADnVQL6s_DRE2aMEw=oBdcu6Bn0Q5CfZ_CKJ4xdGdcp5cRV7w@mail.gmail.com>
 <1409870759.2310959.163817265.10353D86@webmail.messagingengine.com>
 <CAADnVQKT7RC9T9fJBeaBHPHA_=ivEA3jR3QiQ7LQ=8791_C6NQ@mail.gmail.com>
 <CAOJe8K2eQ9ejhBTk7MzJJK5EB4D62U4uKDiFFQFh+T16E7=S3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Denis Kirjanov <kda@linux-powerpc.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48350 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485AbaILIZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 04:25:28 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id F3455208EC
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 04:25:25 -0400 (EDT)
In-Reply-To: <CAOJe8K2eQ9ejhBTk7MzJJK5EB4D62U4uKDiFFQFh+T16E7=S3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Sep 12, 2014, at 09:09, Denis Kirjanov wrote:
> Hi guys, sorry, I was on vacation and didn't notice you. I'll continue to
> work on that.

I have the patch still in my pipeline but just wanted to hear from you
again (or you time out), if you would still like to work on it.
Otherwise will send it out later today.

Bye,
Hannes
