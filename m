From: Andrew Bird <ajb@spheresystems.co.uk>
Subject: Enable some ZTE modems to use the new QMI WWAN driver
Date: Sun, 25 Mar 2012 11:10:26 +0100
Message-ID: <1332670229-2045-1-git-send-email-ajb@spheresystems.co.uk>
Cc: smurf@smurf.noris.de, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches enable the network devices on some Vodafone branded ZTE
devices to be bound by the new QMI / WWAN driver. I suspect that the
K3765-Z would also work, but at the moment I can't get the network
interface to be recognised during probe.

(Reposted as previously I didn't cc netdev)
