From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 08:36:28 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211070834130.11358-100000@shell.cyberus.ca>
References: <20021107120956.GA10832@gnu.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bert hubert <ahu@ds9a.nl>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@gnu.org>
In-Reply-To: <20021107120956.GA10832@gnu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Could you not have used netfilter for this? You have the app
sending controls to add netfilter policies and delete them when not
needed.

cheers,
jamal
