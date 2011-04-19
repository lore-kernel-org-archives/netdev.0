From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next 4/5] be2net: pass domain id to
 be_cmd_link_status_query
Date: Tue, 19 Apr 2011 07:23:02 -0700
Message-ID: <49395329523DD64492581B505F80C86D5A5BCD396B@EXMAIL.ad.emulex.com>
References: <20110418223033.GA9515@akhaparde-VBox>,<20110418.225659.112612060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55567 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752349Ab1DSO1d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 10:27:33 -0400
In-Reply-To: <20110418.225659.112612060.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [davem@davemloft.net]
> Sent: Tuesday, April 19, 2011 12:56 AM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 4/5] be2net: pass domain id to be_cmd_link_status_query

> From: Ajit Khaparde <ajit.khaparde@emulex.com>
> Date: Mon, 18 Apr 2011 17:30:33 -0500

>
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

> That's not all this patch does:
Oh.. sorry about that. I did not realize this. I had worked on these patches over a couple of days
and on one of those days, I seem to have mixed the patches. Will respin these again.


> It seems to be also converting the driver over to the new VLAN
> interfaces.

> Please seperate this part into a seperate patch and resubmit your
> patch series.

> Thanks.