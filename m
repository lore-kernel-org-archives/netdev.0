From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK-PATCH 2.4] IPV6: ensure to evaluate checksum
Date: Thu, 20 May 2004 09:32:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520093207.799834d6.davem@redhat.com>
References: <20040520.193312.19702393.yoshfuji@linux-ipv6.org>
	<20040520081421.594c5447.davem@redhat.com>
	<20040521.005550.20498276.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040521.005550.20498276.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 May 2004 00:55:50 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20040520081421.594c5447.davem@redhat.com> (at Thu, 20 May 2004 08:14:21 -0700), "David S. Miller" <davem@redhat.com> says:
> 
> > I can see both advantages and disadvantages of this
> > behavior.  But what I want to ask is if ipv6 RAW is
> > being different on purpose, for example does the ipv6
> > advanced API specify this perhaps?
> 
> Yes.

Great, I've pulled your 2.4.x raw ipv6 changes into my tree.

Thanks a lot.
