From: =?iso-8859-1?q?I=F1aky_P=E9rez-Gonz=E1lez?=
	<inaky.perez-gonzalez@intel.com>
Subject: Re: [PATCH] i2400m: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 09:56:56 -0800
Message-ID: <200902250956.57394.inaky.perez-gonzalez@intel.com>
References: <49A51B6D.2070107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-wimax@intel.com,
	netdev@vger.kernel.org, wimax@linuxwimax.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:45177 "EHLO
	inaky-mobl3" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753622AbZBZLU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 06:20:26 -0500
In-Reply-To: <49A51B6D.2070107@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 25 February 2009, Wei Yongjun wrote:
> Remove some pointless conditionals before kfree_skb().
>

Applied to the wimax-next tree, thank you.
