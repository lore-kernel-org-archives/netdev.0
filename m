From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM] atm_getaddr() isn't safe
Date: Wed, 3 Sep 2003 20:24:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903202431.2bf3ef82.davem@redhat.com>
References: <200309031625.h83GPFl5022616@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200309031625.h83GPFl5022616@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 03 Sep 2003 12:25:16 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> this patch also preserves the old behavior of atm_getaddr() in
> that it does partially fill in the passed buffer.  please apply
> to 2.6 and 2.4.

Applied, thanks Chas.
