From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] of_mdio: use PTR_ERR_OR_ZERO()
Date: Fri, 11 Mar 2016 14:49:00 -0800
Message-ID: <56E34B5C.9050606@gmail.com>
References: <4882738.uyje2ICxKW@wasted.cogentembedded.com>
 <11956015.EKV4zhDQJ5@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35750 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbcCKWue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 17:50:34 -0500
In-Reply-To: <11956015.EKV4zhDQJ5@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 14:13, Sergei Shtylyov wrote:
> PTR_ERR_OR_ZERO() is open coded in of_phy_register_fixed_link(), so just
> call it directly...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
