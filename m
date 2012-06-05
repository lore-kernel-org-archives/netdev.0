From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH IPROUTE2] tc: Update manpage
Date: Tue, 05 Jun 2012 19:46:32 +0200
Message-ID: <4FCE45F8.2000700@computer.org>
References: <1338916400-9190-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:34907 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754113Ab2FERt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 13:49:56 -0400
In-Reply-To: <1338916400-9190-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2012 07:13 PM, Vijay Subramanian wrote:
> @@ -369,6 +369,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
>  .BR tc-cbq (8),
>  .BR tc-choke (8),
>  .BR tc-codel (8),
> +.BR tc-fq_codel (8),
>  .BR tc-drr (8),
>  .BR tc-htb (8),
>  .BR tc-hfsc (8),

Could I suggest maintaining alphabetic order?
