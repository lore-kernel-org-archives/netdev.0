From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
Date: Fri, 22 Aug 2014 13:31:24 +0200
Message-ID: <1408707084.4349.0.camel@jlt4.sipsolutions.net>
References: <1407827133-29493-1-git-send-email-sanjeev_sharma@mentor.com>
	 <FDC088D3B5555644AE135ED28A7ABDE94DF2FDC2@EU-MBX-02.mgc.mentorg.com>
	 (sfid-20140819_083957_833442_DEE44B0A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "dsd@gentoo.org" <dsd@gentoo.org>,
	"kune@deine-taler.de" <kune@deine-taler.de>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Sharma, Sanjeev" <Sanjeev_Sharma@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FDC088D3B5555644AE135ED28A7ABDE94DF2FDC2@EU-MBX-02.mgc.mentorg.com> (sfid-20140819_083957_833442_DEE44B0A)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-08-19 at 06:39 +0000, Sharma, Sanjeev wrote:
> Ping for review the patch.

Make sure it compiles ...
