From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tg3 shutdown sequence update
Date: Sun, 24 Nov 2002 22:38:50 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021124.223850.79068557.davem@redhat.com>
References: <3DE1C468.1060806@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <3DE1C468.1060806@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff you're posting the "spin_lock_irqsave(tx_lock)" patch
not the one you intended...
