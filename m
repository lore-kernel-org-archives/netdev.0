From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 16:43:07 -0400
Message-ID: <451C33DB.3030908@pobox.com>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net> <Pine.LNX.4.64.0609281552360.28120@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:3208 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750819AbWI1UnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 16:43:11 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609281552360.28120@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another example:  registers often have sensitive information such as WoL 
passwords or WEP keys stored in them.


