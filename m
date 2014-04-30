From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Request for stable inclusion
Date: Wed, 30 Apr 2014 12:56:40 -0700
Message-ID: <1398887800.29914.183.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>
	 <2B0E3F215D1AB84DA946C8BEE234CCC9370ECAF9@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <2B0E3F215D1AB84DA946C8BEE234CCC9370ECAF9@ORSMSX101.amr.corp.intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-30 at 19:40 +0000, Ertman, DavidX M wrote:

> The commit that caused the issue went into net-next on June 21, 2013.  So at least 3.11 and forward, and probably 3.10.

There is a way to know exactly the cut point :

$ git describe --contains da1e2046e5
v3.12-rc1~132^2~445^2~6
