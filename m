From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Wed, 29 Jul 2015 16:25:35 +0300
Message-ID: <55B8D44F.7090800@mellanox.com>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
 <5592913C.3000207@mellanox.com>
 <alpine.LFD.2.11.1506301520180.1799@denkbrett>
 <55929F2D.9050805@mellanox.com>
 <alpine.LFD.2.11.1506301615100.1799@denkbrett> <5593E88F.10006@mellanox.com>
 <alpine.LFD.2.11.1507291449180.1712@denkbrett>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	<netdev@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0057.outbound.protection.outlook.com ([157.56.112.57]:38528
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752664AbbG2N0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 09:26:01 -0400
In-Reply-To: <alpine.LFD.2.11.1507291449180.1712@denkbrett>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/2015 3:50 PM, Sebastian Ott wrote:
> Any updates on this one?

yep, we submitted the patch, see upstream commit 
178d23e3cd4811ebe702d60ac31e8bee389a5847
"net/mlx4_core: Use sink counter for the VF default as fallback"

Or.
