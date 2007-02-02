From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module loadable
 parameter.
Date: Fri, 02 Feb 2007 08:22:58 -0500
Message-ID: <45C33B32.9@garzik.org>
References: <Pine.GSO.4.10.10701311325570.23100-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	alicia.pena@neterion.com, ramkrishna.vepa@neterion.com,
	ananda.raju@neterion.com, sreenivasa.honnur@neterion.com,
	sriram.rapuru@neterion.com, santosh.rastapur@neterion.com
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48264 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423055AbXBBNXE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 08:23:04 -0500
In-Reply-To: <Pine.GSO.4.10.10701311325570.23100-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sivakumar Subramani wrote:
> This patch adds two load parameters napi and ufo. Previously NAPI was
> compilation option with these changes wan enable disable NAPI using load
> parameter. Also we are introducing ufo load parameter to enable/disable
> ufo feature
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

applied patches 1-5, yay :)


