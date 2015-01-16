From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH 0/2] Remove T4 FCoE support
Date: Fri, 16 Jan 2015 08:19:41 +0100
Message-ID: <54B8BB8D.8050602@suse.de>
References: <cover.1421328605.git.praveenm@chelsio.com> <20150115.140453.871607276763972458.davem@davemloft.net> <20150116042616.GA1264@fcoe-test11>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, varun@chelsio.com
To: Praveen Madhavan <praveenm@chelsio.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20150116042616.GA1264@fcoe-test11>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/2015 05:32 AM, Praveen Madhavan wrote:
> On Thu, Jan 15, 2015 at 02:04:53PM -0500, David Miller wrote:
>> From: Praveen Madhavan <praveenm@chelsio.com>
>> Date: Thu, 15 Jan 2015 19:15:50 +0530
>>
>>> These patches removes FCoE support for chelsio T4 adapter.
>>> Please apply on net-next since depends on previous commits.
>>
>> Why is it being removed?  You have to state this in the
>> commit log messages at a minimum.
>>
> We found a subtle issue with FCoE on T4 very late in the game=20
> and decided not to productize FCoE on T4 and therefore there=20
> are no customers that will be impacted by this change. FCoE is
> supported on T5 cards.
> Sorry about that, not mentioning in commit log. Can i resend this=20
> patch with updated commit log?
> =20
Yes, please do.

Cheers,

Hannes
--=20
Dr. Hannes Reinecke		               zSeries & Storage
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: F. Imend=F6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=FCrnberg)
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
