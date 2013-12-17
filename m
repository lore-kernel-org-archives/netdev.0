From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/2] ovs: introduce arch-specific
 fast hashing improvements
Date: Tue, 17 Dec 2013 14:28:07 -0500 (EST)
Message-ID: <20131217.142807.253658638726176962.davem@davemloft.net>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ffusco-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1386860946-1621-1-git-send-email-ffusco-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Francesco Fusco <ffusco-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Thu, 12 Dec 2013 16:09:04 +0100

> From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> We are introducing a fast hash function (see patch1) that can be
> used in the context of OpenVSwitch to reduce the hashing footprint
> (patch2). For details, please see individual patches!
> 
> Thanks !
> 
> v1->v2:
>  - Make hash generic and place it under lib

Series applied, thanks.
