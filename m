From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH iproute2] tc-sfq: update man page
Date: Tue, 31 Jan 2012 21:11:44 +0100
Message-ID: <4F284B00.3080908@computer.org>
References: <1327411778.7231.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4F27E0C4.1050609@computer.org> <1328023680.2297.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:1477 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530Ab2AaUNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 15:13:25 -0500
In-Reply-To: <1328023680.2297.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2012 04:28 PM, Eric Dumazet wrote:
> Packets of other protocol (so not UDP, not TCP...) are hashed based on 
> their source IP _and_ destination IP Old documentation wrongly stated 
> the hash was done only based on destination IP. Also we no longer uses 
> 'local socket' since SFQ uses standard rxhash or flow dissector. 
Fair enough, thanks
