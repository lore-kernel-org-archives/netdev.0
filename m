From: jamal <hadi@cyberus.ca>
Subject: Re: route cache and messed up network
Date: 29 Sep 2003 22:31:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064889101.1024.27.camel@jzny.localdomain>
References: <1064865515.8417.2.camel@dlacoste.ottawa.loran.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dana Lacoste <dana.lacoste@peregrine.com>
In-Reply-To: <1064865515.8417.2.camel@dlacoste.ottawa.loran.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Why dont you just ignore redirects on the Linux machine?
echo 0 > /proc/sys/net/ipv4/conf/*/accept_redirects

cheers,
jamal
