From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [PATCH 9/9] treewide: Inline ib_dma_map_*() functions
Date: Thu, 12 Jan 2017 13:45:31 +0200
Message-ID: <811bac91-39f4-edac-db8a-d44989440b21@grimberg.me>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
 <20170111005648.14988-10-bart.vanassche@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ron Minnich <rminnich-4OHPYypu0djtX7QSmKvirg@public.gmane.org>,
        James Simmons <jsimmons-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org
To: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170111005648.14988-10-bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Reviewed-by: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
