From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: netdev-2.6 queue updated
Date: Fri, 7 Jan 2005 20:04:26 +0100
Message-ID: <20050107190426.GA17017@electric-eye.fr.zoreil.com>
References: <41DE73B5.6080303@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41DE73B5.6080303@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
>   o r8169: oversized driver field for ethtool
>   o r8169: reduce max MTU for large frames
>   o r8169: Large Send enablement
>   o r8169: C 101
>   o r8169: missing netif_poll_enable and irq ack

Imho you can push these changes to mainline (with due credit to
Jon D Mason for its contributions).

--
Ueimor
