From: "Simon Barber" <simon@instant802.com>
Subject: Root qdisc implementation
Date: Mon, 23 Feb 2004 14:54:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <AC8C1F46CD753F4AAC8F890E35A9EB461C66EC@webmail.instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is there any way to tell when a qdisc is being installed that it is the
root qdisc on a device? (to enforce that a certain qdisc can only be
installed as root).

Does a root qdisc need to implement drop or requeue?

Simon
