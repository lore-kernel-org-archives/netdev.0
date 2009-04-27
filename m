From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: use max() instead of VXGE_HW_SET_LEVEL
Date: Mon, 27 Apr 2009 03:03:22 -0700 (PDT)
Message-ID: <20090427.030322.241078407.davem@davemloft.net>
References: <1240538001-11386-1-git-send-email-a.beregalov@gmail.com>
	<78C9135A3D2ECE4B8162EBDCE82CAD7705313EF0@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, netdev@vger.kernel.org
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48622
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752339AbZD0KD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:03:29 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705313EF0@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Fri, 24 Apr 2009 01:05:27 -0400

>> Subject: [PATCH] vxge: use max() instead of VXGE_HW_SET_LEVEL
>> 
>> 
>> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> 
> Looks good, thanks.
> 
> Acked-by: Ram Vepa <ram.vepa@neterion.com>

Applied to net-next-2.6
