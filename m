From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] hso: Earlier catch of error condition
Date: Wed, 21 Aug 2013 20:48:15 -0700 (PDT)
Message-ID: <20130821.204815.365691453186727923.davem@davemloft.net>
References: <1377074587.4530.8.camel@chimera>
	<20130821162507.GD14364@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@gimpelevich.san-francisco.ca.us, j.dumon@option.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130821162507.GD14364@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Wed, 21 Aug 2013 09:25:07 -0700

> On Wed, Aug 21, 2013 at 01:43:07AM -0700, Daniel Gimpelevich wrote:
>> There is no need to get an interface specification if we know it's the
>> wrong one. 
>> 
>> Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
> 
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Applied.
