From: Andrew Beverley <andy@andybev.com>
Subject: RE: IP forwarding on a linux IPSec gateway
Date: Tue, 31 Jan 2012 22:15:55 +0000
Message-ID: <1328048155.1630.0.camel@andy-laptop>
References: <B97B134FACB2024DB45F524AB0A7B7F2059F2B32@XMB-BGL-419.cisco.com>
	 <1328032051.2018.15.camel@andy-laptop>
	 <B97B134FACB2024DB45F524AB0A7B7F205B93C54@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earth.simplelists.com ([89.16.184.171]:56251 "EHLO
	earth.simplelists.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040Ab2AaWQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 17:16:12 -0500
In-Reply-To: <B97B134FACB2024DB45F524AB0A7B7F205B93C54@XMB-BGL-419.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 23:41 +0530, Prashant Batra (prbatra) wrote:
> Any links to understand the flow in the kernel for this kind of
> forwarding with IPSec to analyze where the problem could be will be
> really helpful.

Does this excellent diagram from Jan help at all?

http://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg

Andy
