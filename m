From: bert hubert <ahu@ds9a.nl>
Subject: Re: Very slow change of IP in kernel (slow socket?).
Date: Wed, 22 Dec 2004 09:27:20 +0100
Message-ID: <20041222082720.GA26089@outpost.ds9a.nl>
References: <41C895D6.2040001@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Andrea G Forte <andreaf@cs.columbia.edu>
Content-Disposition: inline
In-Reply-To: <41C895D6.2040001@cs.columbia.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 21, 2004 at 04:29:58PM -0500, Andrea G Forte wrote:

> Does anyone of you know what this could be related to? Or, does anyone 

'ip route flush cache' may help.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
