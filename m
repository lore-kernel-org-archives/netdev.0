From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Mon, 1 Sep 2014 22:28:51 +0200
Message-ID: <20140901202851.GA1862@nanopsycho.lan>
References: <20140826152217.GA1843@nanopsycho.lan>
 <53FCA7C6.5070804@mojatatu.com>
 <20140826154459.GB1843@nanopsycho.lan>
 <20140826155426.GA5275@gospo.rtplab.test>
 <20140826161956.GA15316@casper.infradead.org>
 <CAADnVQLeNTQO9rekWRAb_2MWgiZqEiZ4p6GAsypdkhgg3xQffw@mail.gmail.com>
 <20140826205419.GH15316@casper.infradead.org>
 <54008C47.5040503@mojatatu.com>
 <20140901081343.GC12731@vergenet.net>
 <5404A0B1.1030009@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, ben@decadent.org.uk,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	john.r.fastabend@intel.com, Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Lin
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:55119 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaIAU24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 16:28:56 -0400
Received: by mail-la0-f43.google.com with SMTP id ty20so6594446lab.2
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 13:28:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5404A0B1.1030009@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 01, 2014 at 06:37:05PM CEST, jhs@mojatatu.com wrote:
>On 09/01/14 04:13, Simon Horman wrote:
>>On Fri, Aug 29, 2014 at 10:20:55AM -0400, Jamal Hadi Salim wrote:
>
>>>I actually have no issues with whatever classifier someone decides
>>>to use. To each their poison. But I do take issue mandating the
>>>specified classifer it as THE CLASSIFIER as in this case,
>>>is where i start taking issue. I have a few things that i offload
>>>to hardware with speacilized classifiers such that i object strongly
>>>to the approach this driver has taken.
>>
>>My reading of this thread is that allowing different classifiers
>>is not under dispute.
>
>
>I am not sure how you reached that conclusion by reading this thread;->
>But i would be glad if that was the conclusion and i missed it.

Jamal, please be ensured that no one I know of is against future
different classifiers.
