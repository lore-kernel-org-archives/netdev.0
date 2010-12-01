From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: multi bpf filter will impact =?UTF-8?Q?performance=3F?=
Date: Wed, 01 Dec 2010 18:22:48 +0100
Message-ID: <18eaf7d286236427b1632b9af62be513@localhost>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
 <1291109699.2904.11.camel@edumazet-laptop>
 <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
 <1291127670.2904.96.camel@edumazet-laptop>
 <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
 <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com>
 <1291189649.2856.478.camel@edumazet-laptop>
 <AANLkTinQ9c_C6LzNf5c3BbJXQTVKmbqf6KR9K23tGETw@mail.gmail.com>
 <1291190956.2856.485.camel@edumazet-laptop>
 <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
 <1291192967.2856.492.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, Rui <wirelesser@gmail.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39086 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753150Ab0LARWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 12:22:50 -0500
In-Reply-To: <1291192967.2856.492.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 01 Dec 2010 09:42:47 +0100, Eric Dumazet wrote:



> IMHO, a better pcap optimizer would be the first step.



+1



Optimizing complex filter rules is step one in the process of optimizing

the packet processing. A JIT compiler like FreeBSD provides cannot polish a

(pcap)turd. I thought Patrick was working on a generic filter mechanism for

netfilter!? ... ;)



Hagen


