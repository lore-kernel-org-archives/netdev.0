From: David Miller <davem@davemloft.net>
Subject: Re: Small fixes/changes for RDS
Date: Fri, 03 Oct 2014 12:52:59 -0700 (PDT)
Message-ID: <20141003.125259.1940750405354043575.davem@davemloft.net>
References: <1412200194-28902-1-git-send-email-herton@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rmanes@redhat.com, dledford@redhat.com
To: herton@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412200194-28902-1-git-send-email-herton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Herton R. Krzesinski" <herton@redhat.com>
Date: Wed,  1 Oct 2014 18:49:51 -0300

> I got a report of one issue within RDS (after investigation it was a double
> free), and I'm sending the fix (patch 3/3) which reporter said it works (no more
> WARNING triggered on a specially instrumented kernel). The report/test was done
> on a very old kernel (RHEL 5, 2.6.18 based with backports), but the problem the
> patch handles still exists and should not change. Besides that, while
> reviewing some of the code but being unable to reproduce with rds_tcp, I
> noticed two small improvements/fixes which are in patches 1 and 2.

Series applied, thanks.
