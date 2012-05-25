From: Yeoh Chun-Yeow <yeohchunyeow@gmail.com>
Subject: Re: [RFC] mac80211: Use correct originator sequence number in a Path Reply
Date: Sat, 26 May 2012 00:31:57 +0800
Message-ID: <CAEFj987dNMyMcS9rySzVpfY0Fo5t0LtL9FZg770ohKi+bDO9ZA@mail.gmail.com>
References: <1337934071-29342-1-git-send-email-qasimj@gmail.com>
	<CAEFj985HxSrOwOoevDjG1jxPxobLda-X_LZUtj6LgwXZwozBog@mail.gmail.com>
	<CAJivULpmLp9JK+PQZ9RkrvvYHNk=uA33=A-ffftroigivy1_NQ@mail.gmail.com>
	<CAEFj984efuO12nSPsZ2A0Q0nwPLesYJ8gDHwgh=0e1VO3_UtGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ravip@utdallas.edu
To: devel@lists.open80211s.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEFj984efuO12nSPsZ2A0Q0nwPLesYJ8gDHwgh=0e1VO3_UtGw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think that the PREQ element has originator sequence number at the
> end but the PREQ element has the target sequence number at the end.
> This is what mesh_path_sel_frame_tx is doing.

PREP element has originator sequence number at the end but the PREQ
element has the target sequence number at the end.

Regards,
Chun-Yeow
