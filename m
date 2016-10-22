From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] udp: refactor memory accounting
Date: Sat, 22 Oct 2016 16:50:28 -0400 (EDT)
Message-ID: <20161022.165028.1826469214601163183.davem@davemloft.net>
References: <cover.1477043395.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
        trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org,
        hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1477043395.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Fri, 21 Oct 2016 13:55:44 +0200

> This patch series refactor the udp memory accounting, replacing the
> generic implementation with a custom one, in order to remove the needs for
> locking the socket on the enqueue and dequeue operations. The socket backlog
> usage is dropped, as well.
 ...

Series applied, thank you.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
