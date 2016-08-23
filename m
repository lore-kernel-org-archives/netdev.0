From: Luis Henriques <luis.henriques@canonical.com>
Subject: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 14:41:07 +0100
Message-ID: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Avijit Kanti Das <avijitnsec@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Digging through some old CVEs I came across this one that doesn't seem be
in mainline.  Was there a good reason for not being sent upstream?  Maybe it was
rejected for some reason and I failed to find the discussion.

References:
 https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-9900
 http://source.android.com/security/bulletin/2016-08-01.html
 https://source.codeaurora.org/quic/la/kernel/msm-3.10/commit/?id=63c317dbee97983004dffdd9f742a20d17150071

Cheers,
--
Luís
