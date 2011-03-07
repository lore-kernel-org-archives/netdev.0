From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate
 name service errors
Date: Mon, 7 Mar 2011 16:00:42 +0000
Message-ID: <20110307160042.2ddc8e65@lxorguk.ukuu.org.uk>
References: <20110307150208.28218.89348.stgit@warthog.procyon.org.uk>
	<20110307150218.28218.84916.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-6DNke4IJHB0gsBAKwltoeQ@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110307150218.28218.84916.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Define ENONAMESERVICE to indicate "Network name service unavailable".  This can
> be used to indicate, for example, that an attempt was made by dns_query() to
> make a query, but the name server (e.g. a DNS server) it is supposed to contact
> didn't answer or that it couldn't determine the location of a suitable server.

Are these in glibc and are there glibc patches submitted and accepted for
this ?

(I only ask because I know its previously taken years for glibc to catch
up with stuff)
