From: rask@sygehus.dk (Rask Ingemann Lambertsen)
Subject: Where is netif_rx() not safe to use?
Date: Mon, 12 May 2003 15:45:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <43428.9386998445$1052747126@news.gmane.org>
Reply-To: rask@sygehus.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi.

I'd like to know if there are situations where netif_rx() is not safe to use. For example, is it safe to call from a timer or from dev->poll()?

Regards,
Rask Ingemann Lambertsen
