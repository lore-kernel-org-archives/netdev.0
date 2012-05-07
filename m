From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: batostr() function
Date: Mon, 07 May 2012 13:49:43 +0200
Message-ID: <1336391383.4325.24.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Really? 2 static buffers that are used alternately based on a static
variable? How can that possibly be thread-safe? That may work in very
restricted scenarios, but ...

johannes
