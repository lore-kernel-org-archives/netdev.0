From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bisect'ed BUG in VLAN promisc mode (6c78dcbd47)
Date: Tue, 07 Oct 2008 13:10:43 +0200
Message-ID: <48EB43B3.5000603@trash.net>
References: <1222437636.7598.14.camel@localhost.localdomain>	 <48DD0A4F.6020703@trash.net>	 <1222456933.2381.3.camel@localhost.localdomain> <48DD36D2.90103@trash.net>	 <48DD37E3.9090706@trash.net>	 <1222457670.2381.8.camel@localhost.localdomain> <48DD3AD5.80800@trash.net>	 <Pine.LNX.4.64.0810021835390.8590@tyr.diku.dk> <48E9F07E.9060609@trash.net> <1223377397.26666.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41682 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbYJGLKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 07:10:50 -0400
In-Reply-To: <1223377397.26666.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Mon, 2008-10-06 at 13:03 +0200, Patrick McHardy wrote:
>> Jesper Dangaard Brouer wrote:
>>> Patrick promised he would do a more clean fix later ;-)
>> And here it is. Could you verify that it also fixes the problem?
> 
> It works and fixes the problem -- thanks!
> 
> Tested-by: Jesper Dangaard Brouer <jdb@comx.dk>

Thanks Jesper.

