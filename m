From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 11/13] Hide MAX_RAW_MINORS behind #ifdef __KERNEL__
Date: Thu, 10 Sep 2015 12:13:34 +0100
Message-ID: <18103.1441883614@warthog.procyon.org.uk>
References: <1441832902-28993-12-git-send-email-palmer@dabbelt.com> <2644177.lVCYzIBfPW@wuerfel> <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, arnd@arndb.de, 3chas3@gmail.com,
	hpa@zytor.com, mingo@redhat.com, plagnioj@jcrosoft.com,
	jikos@kernel.org, linux-api@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tglx@linutronix.de, tomi.valkeinen@ti.com,
	x86@kernel.org
To: Palmer Dabbelt <palmer@dabbelt.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441832902-28993-12-git-send-email-palmer@dabbelt.com>
Content-ID: <18102.1441883614.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Palmer Dabbelt <palmer@dabbelt.com> wrote:

> I don't think this was ever meant to be exposed to userspace.

Then it should be in include/linux/raw.h

David
