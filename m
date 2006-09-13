From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for 'r8169-20060912-00' branch
Date: Tue, 12 Sep 2006 22:04:09 -0400
Message-ID: <45076719.4000504@garzik.org>
References: <20060912193531.GB4482@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49541 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751495AbWIMCEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 22:04:11 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060912193531.GB4482@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from tag 'r8169-20060912-00' in repository
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git
> 
> to get the change below:
> 
> (patch applies to jeff#upstream-linus)
> 
> Notes:
> - the so far unsupported 8136 needs to be kicked with mii-tool to get
>   the link right ;
> - the 8168 works fine ;
> - the 8119sb now works on iop3xx ARM ;
> - the prom of my sparc64 is filled with 0xff. I can't test on big endian
>   any more, help !

pulled, same comment as with 8139cp


