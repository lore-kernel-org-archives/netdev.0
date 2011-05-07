From: julie Sullivan <kernelmail.jms@gmail.com>
Subject: Re: [PATCH] [RESEND] iwl4965: drop a lone pr_err()
Date: Sat, 7 May 2011 21:14:52 +0100
Message-ID: <BANLkTinE4zDXE6VDS=yc1SmCCEbAn70Rcw@mail.gmail.com>
References: <1304771519.2227.6.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304771519.2227.6.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> iwl4965_rate_control_register() prints a message at KERN_ERR level.

> - =A0 =A0 =A0 pr_err("Registering 4965 rate control operations\n");

Yes, I noticed this message on boot too and found it a tad confusing...
('Rate control operations'?? 4,965 of them?)
:-)  At least I know what it is now. Thanks, Paul.

Julie
