From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM] don't export llc_oui
Date: Thu, 11 Sep 2003 18:15:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911181526.4dbd7794.davem@redhat.com>
References: <200309082050.h88KoUSa003672@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com, mitch@sfgoth.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200309082050.h88KoUSa003672@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 08 Sep 2003 16:50:30 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> llc_oui[] is only used in two places.  the overhead of exporting
> probably isnt worth the effort.  please apply to 2.6. -- thanks!

Applied, thanks.
