From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] add iocb to network protocols
Date: Thu, 10 Oct 2002 16:22:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010.162240.102769920.davem@redhat.com>
References: <20021010183528.A13432@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@redhat.com
In-Reply-To: <20021010183528.A13432@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


+#include <net/scm.h>	/* for sock_iocb */

What is this?
