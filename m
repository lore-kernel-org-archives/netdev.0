From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Mon, 01 Sep 2014 21:08:51 -0400
Message-ID: <540518A3.7020909@mojatatu.com>
References: <20140826152217.GA1843@nanopsycho.lan> <53FCA7C6.5070804@mojatatu.com> <20140826154459.GB1843@nanopsycho.lan> <20140826155426.GA5275@gospo.rtplab.test> <20140826161956.GA15316@casper.infradead.org> <CAADnVQLeNTQO9rekWRAb_2MWgiZqEiZ4p6GAsypdkhgg3xQffw@mail.gmail.com> <20140826205419.GH15316@casper.infradead.org> <54008C47.5040503@mojatatu.com> <20140901081343.GC12731@vergenet.net> <5404A0B1.1030009@mojatatu.com> <20140901202851.GA1862@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:32882 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbaIBBI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:08:57 -0400
Received: by mail-ie0-f179.google.com with SMTP id tr6so6846601ieb.38
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 18:08:56 -0700 (PDT)
In-Reply-To: <20140901202851.GA1862@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 16:28, Jiri Pirko wrote:

> Jamal, please be ensured that no one I know of is against future
> different classifiers.
>

Ok, glad to hear that.
The patches and/or some of the discussion were not projecting that
view. Even for the flow case, I am pretty sure we are going to
need a few iterations before we settle on a general consensus.

cheers,
jamal
