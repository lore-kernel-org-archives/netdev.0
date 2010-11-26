From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/5] HID: roccat: declaring meaning of pack pragma
 usage in driver headers
Date: Fri, 26 Nov 2010 20:50:16 +0000
Message-ID: <1290804616.3051.52.camel@localhost>
References: <1290801456.18750.164.camel@neuromancer>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Jiri Kosina <jkosina@suse.cz>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-input@vger.kernel.org,
	netdev@vger.kernel.org
To: erazor_de@users.sourceforge.net
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1290801456.18750.164.camel@neuromancer>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-11-26 at 20:57 +0100, Stefan Achatz wrote:
> Using pack pragma to prevent padding bytes in binary data structures
> used for hardware communication. Explanation of these pragmas was requested.
[...]

It would be clearer to use the '__packed' macro after each structure
definition instead of using this awful Microsoft extension.

Ben. 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

