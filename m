From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [patch 2.6.17] s2io driver irq fix
Date: Thu, 22 Jun 2006 22:54:23 -0700
Message-ID: <adalkrol8mo.fsf@cisco.com>
References: <Pine.GSO.4.10.10606211537540.23949-100000@guinness>
	<20060621211534.b740d0f8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dgc@sgi.com, balbir@in.ibm.com, viro@zeniv.linux.org.uk,
	neilb@suse.de, jblunck@suse.de, tglx@linutronix.de,
	leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	alicia.pena@neterion.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060621211534.b740d0f8.akpm@osdl.org> (Andrew Morton's message of "Wed, 21 Jun 2006 21:15:34 -0700")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Andrew> Is it usual to prohibit IRQ sharing with msix?

With current code at least, MSI/MSI-X interrupts can never be shared.

 - R.
