From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.9-rc3-mm1] 3c59x: Make use of generic_mii_ioctl
Date: Mon, 4 Oct 2004 14:04:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004140405.2244226a.akpm@osdl.org>
References: <20041003204507.GA29546@bayes.mathematik.tu-chemnitz.de>
	<20041004115201.GA1635@bayes.mathematik.tu-chemnitz.de>
	<4161B050.2070509@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4161B050.2070509@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> Patch looks OK to me... Andrew, you got this?

Yup.  Hugh sent a fix through to make CONFIG_VORTEX select CONFIG_MII too.
