From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] hso: Earlier catch of error condition
Date: Wed, 21 Aug 2013 09:25:07 -0700
Message-ID: <20130821162507.GD14364@kroah.com>
References: <1377074587.4530.8.camel@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377074587.4530.8.camel@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 21, 2013 at 01:43:07AM -0700, Daniel Gimpelevich wrote:
> There is no need to get an interface specification if we know it's the
> wrong one. 
> 
> Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
