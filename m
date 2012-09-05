From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V2 PATCH 1/9] csiostor: Chelsio FCoE offload driver submission
 (sources part 1).
Date: Wed, 5 Sep 2012 22:48:24 +0530
Message-ID: <50478960.5000003@chelsio.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com> <1346848442-4573-2-git-send-email-naresh@chelsio.com> <20120905092326.0a54226f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1907 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab2IERSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 13:18:37 -0400
In-Reply-To: <20120905092326.0a54226f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/2012 9:53 PM, Stephen Hemminger wrote:
> On Wed,  5 Sep 2012 18:03:54 +0530
> Naresh Kumar Inna <naresh@chelsio.com> wrote:
> 
>> +
>> +/* FCoE Adapter types & its description */
>> +static struct csio_adap_desc csio_fcoe_adapters[] = {
> 
> Tables like this should be const.
> 

Thanks for reviewing. I will change it to const.
