From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V2 PATCH 6/9] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Wed, 5 Sep 2012 22:56:14 +0530
Message-ID: <50478B36.6000103@chelsio.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com> <1346848442-4573-7-git-send-email-naresh@chelsio.com> <20120905093133.5f97fcbb@nehalam.linuxnetplumber.net>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120905093133.5f97fcbb@nehalam.linuxnetplumber.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/5/2012 10:01 PM, Stephen Hemminger wrote:
> On Wed,  5 Sep 2012 18:03:59 +0530
> Naresh Kumar Inna <naresh@chelsio.com> wrote:
> 
>> +#define CSIO_ROUNDUP(__v, __r)		(((__v) + (__r) - 1) / (__r))
> 
> This is similar to existing round_up() in kernel.h could you use that?
> 
I will replace it with round_up() if it serves the same purpose. Thanks.
