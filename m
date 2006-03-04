From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/2] natsemi: NAPI and a bugfix
Date: Sat, 04 Mar 2006 12:15:08 -0500
Message-ID: <4409CB1C.7060201@pobox.com>
References: <20060202233909.426660000@lorien.sirena.org.uk> <20060202235155.775450000@lorien.sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932217AbWCDRP0@vger.kernel.org>
To: Mark Brown <broonie@sirena.org.uk>
In-Reply-To: <20060202235155.775450000@lorien.sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> This patch converts the natsemi driver to use NAPI.  It was originally
> based on one written by Harald Welte, though it has since been modified
> quite a bit, most extensively in order to remove the ability to disable
> NAPI since none of the other drivers seem to provide that functionality
> any more.
> 
> Signed-off-by: Mark Brown <broonie@sirena.org.uk>

applied 1-2
