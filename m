From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: quick help with bonding?
Date: Mon, 02 Apr 2007 16:28:17 -0600
Message-ID: <46118381.5030801@nortel.com>
References: <460BE5F0.7070606@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	ctindel@users.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:62176 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965983AbXDBW2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 18:28:35 -0400
In-Reply-To: <460BE5F0.7070606@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:

> It behaved fairly well with standard networking, but its behaving 
> strangely with bonding added to the mix.

Thanks to everyone for the suggestions and help.

It turns out it was actually a driver problem that was more easily 
manifested by the timing of the way bonding changed the link MTU.

Chris
