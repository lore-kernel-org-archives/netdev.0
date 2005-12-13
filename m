From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] natsemi: NAPI support
Date: Mon, 12 Dec 2005 19:25:20 -0500
Message-ID: <439E14F0.4040001@pobox.com>
References: <20051204224734.GA12962@sirena.org.uk> <20051204231209.GA28949@electric-eye.fr.zoreil.com> <20051205232301.GA4551@sirena.org.uk> <20051206001934.GA18329@electric-eye.fr.zoreil.com> <20051206211729.GB3709@sirena.org.uk> <20051206215619.GB3425@electric-eye.fr.zoreil.com> <20051209104832.GA3677@sirena.org.uk> <20051212235531.GB3714@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932272AbVLMAZj@vger.kernel.org>
To: Mark Brown <broonie@sirena.org.uk>
In-Reply-To: <20051212235531.GB3714@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> This patch against 2.6.14 converts the natsemi driver to use NAPI.  It
> was originally based on one written by Harald Welte, though it has since
> been modified quite a bit, most extensively in order to remove the
> ability to disable NAPI since none of the other drivers seem to provide
> that functionality any more.
> 
> Signed-off-by: Mark Brown <broonie@sirena.org.uk>

Was it updated per the comments you received on the first posting?

	Jeff
